package ApiCommonWorkflow::Main::WorkflowSteps::ImportOrthomclTestData;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  # three cases:
  # 1) no taxaDir supplied:  filter based on inputProteinFile
  # 2) taxaDir supplied, and no table called ApiDB.SimilarSequences${suffix}_c exists:  filter based on taxa in taxaDir
  # 3) taxaDir supplied, and ApiDB.SimilarSequences${suffix}_c exists:  use that table (drop ApiDB.SimilarSequences$suffix and use a synonym)

  my $taxaDir = $self->getParamValue('taxaDir');
  my $suffix = $self->getParamValue('suffix');
  my $collapseClades = $self->getBooleanParamValue('collapseClades');
  my $inputProteinFile = $self->getParamValue('inputProteinFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cacheTableName = "SimSeq_${suffix}_c";

  my ($cacheTableExists) = $self->runSqlFetchOneRow($test, <<SQL) if ($taxaDir);
      select count(*) from all_tables
      where owner = 'APIDB' and table_name = upper('$cacheTableName')
SQL

  if ($undo) {
    #no need to drop synonym on undo, because it's created with "create or replace synonym"
      if (!$cacheTableExists) {
	  $self->runSqlFetchOneRow($test, "truncate table apidb.SimilarSequences$suffix");
      }
  } else {
      if (!$taxaDir) {
	  my $suf = $suffix? "-suffix $suffix" : "";
	  my $cc = $collapseClades? "-collapseClades" : "";
	  $self->runCmd($test, "filterSimsByProteinIdsInMemory $suf -proteinsFile $workflowDataDir/$inputProteinFile $cc");
      } else {
	  if ($cacheTableExists) {
	      $self->createSynonym($test, $suffix, $cacheTableName);
	  } else {
	    $self->runCmd($test, "filterSimilarSequencesByTaxon -suffix $suffix -taxaDir $workflowDataDir/$taxaDir");
	  }
      }
  }
}

# Plan A Tier 1
# drop apidb.SimilarSequences$suffix table if it exists
# create synonym called "apidb.SimilarSequences$suffix" that points to cache table apidb.SimilarSequences$suffix_c
sub createSynonym {
    my ($self, $test, $suffix, $cacheTableName) = @_;

    my ($simSeqExists) = $self->runSqlFetchOneRow($test, <<SQL);
      select count(*) from all_tables
      where owner = 'APIDB' and table_name = upper('SimilarSequences${suffix}')
SQL

    if ($simSeqExists) {
      $self->runSqlFetchOneRow($test, <<SQL);
         alter table apidb.SimilarSequences${suffix} rename to SimSeqs${suffix}_sv
SQL
    }

    $self->runSqlFetchOneRow($test, <<SQL);
      create or replace synonym apidb.SimilarSequences${suffix} for apidb.$cacheTableName
SQL
}

# Plan B Tier 1
sub filterOnTaxa {
}


