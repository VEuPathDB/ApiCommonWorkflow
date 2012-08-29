package ApiCommonWorkflow::Main::WorkflowSteps::ImportOrthomclTestData;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;
 
  # as a preprocess we ran a plsql script to partition the big simseqs table by clade.
  # these are the "cache" tables and are named ApiDB.SimilarSequences${suffix}_c
  # where suffix = an ncbi taxon id of clade

  # four cases:

  # 1) Plan A Tier 1
  #     - taxaDir supplied. ApiDB.SimilarSequences${suffix}_c might exist or might not.  if so  use that table (drop ApiDB.SimilarSequences$suffix and use a synonym). 
  # 2) Plan A Tier 2 
  #     - no taxaDir supplied.  filter based on inputProteinFile (rep proteins).  "collapse clades" by prepending clade ID protein ID.

  # 3) Plan B Tier 1
  #     - taxaDir supplied and no table called ApiDB.SimilarSequences${suffix}_c exists.  filter based on taxa in taxaDir. 
  # 4) Plan B Tier 2
  #     - no taxaDir supplied:  filter based on inputProteinFile (residuals).   do not "collapse clades"


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
      if ($taxaDir) {
	  if ($cacheTableExists) {
	      $self->createSynonym($test, $suffix, $cacheTableName);
	  } else {
	    $self->runCmd($test, "filterSimilarSequencesByTaxon -suffix $suffix -taxaDir $workflowDataDir/$taxaDir -verbose");
	  }
      } else {
	  my $suf = $suffix? "-suffix $suffix" : "";
	  my $cc = $collapseClades? "-collapseClades" : "";
	  $self->runCmd($test, "filterSimsByProteinIdsInMemory $suf -proteinsFile $workflowDataDir/$inputProteinFile -simsFile /eupath/data/EuPathDB/devWorkflows/OrthoMCL/testdata/SimilarSequences.dat.gz $cc -verbose");
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


