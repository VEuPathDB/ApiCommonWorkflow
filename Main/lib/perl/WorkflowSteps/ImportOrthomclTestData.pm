package ApiCommonWorkflow::Main::WorkflowSteps::ImportOrthomclTestData;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  # three cases:
  # 1) no taxaDir supplied:  filter based on inputProteinFile
  # 2) taxaDir supplied, and no table called ApiDB.SimilarSequences${suffix}_1 exists:  filter based on taxa in taxaDir
  # 3) taxaDir supplied, and ApiDB.SimilarSequences${suffix}_1 exists:  use that table (drop ApiDB.SimilarSequences$suffix and use a synonym)

  my $taxaDir = $self->getParamValue('taxaDir');
  my $suffix = $self->getParamValue('suffix');
  my $inputProteinFile = $self->getParamValue('inputProteinFile');

  my $cacheTableName = "ApiDB.SimilarSequences${suffix}_c"
  my $sql = "sql to find number of tables";
  my $cacheTableExists = $taxaDir && $self->runSqlFetchOneRow($test, "$sql");


  if ($undo) {
      if ($tableExists) {
	  $sql = "sql to remove synonym";
	  $self->runSqlFetchOneRow($test, "$sql");
      } else {
	  $self->runSqlFetchOneRow($test, "truncate table apidb.SimilarSequences$suffix");
      }
  } else {
      if (!$taxaDir) {
	  $self->filterOnProteinIds($inputProteinFile, $suffix);
      } else {
	  if ($tableExists) {
	      $self->createSynonym($suffix);
	  } else {
	      $self->filterOnTaxa($taxaDir, $suffix);
	  }
      }
  }
}

sub filterOnProteinIds {
}

# drop apidb.SimilarSequences$suffix if it exists
# create synonym
sub createSynonym {
}

sub filterOnTaxa {
    chdir $taxaDir || die "Can't chdir to '$taxaDir'\n";
    my @taxonNames = map {/(\w+).fasta/; $1; } <*.fasta>;
    my $taxonList = join(', ', @taxonNames);

    $sql = <<"SQL";
          insert into apidb.SimilarSequences$suffix
                      (query_id, subject_id, query_taxon_id, subject_taxon_id,
                       evalue_mant, evalue_exp, percent_identity, percent_match)
          select query_id, subject_id, query_taxon_id, subject_taxon_id,
                 evalue_mant, evalue_exp, percent_identity, percent_match
          from apidb.SimilarSequences\@orth500n
          where query_taxon_id in ($taxonList)
            and subject_taxon_id in ($taxonList)
SQL

    $self->runSqlFetchOneRow($test, $sql);
}
