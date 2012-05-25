package ApiCommonWorkflow::Main::WorkflowSteps::ImportOrthomclTestData;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $taxonDir = $self->getParamValue('taxonDir');
  my $suffix = $self->getParamValue('suffix');

  if ($undo) {
    $self->runCmd($test, "executeIdSQL.pl --idSQL \"truncate table apidb.SimilarSequences$suffix\" ");
  } else {

    chdir $taxonDir;
    my $taxonList = join(', ', map("'$_'", <*>));

    my $sql = <<"SQL";
          insert into apidb.SimilarSequences$suffix
                      (query_id, subject_id, query_taxon_id, subject_taxon_id,
                       evalue_mant, evalue_exp, percent_identity, percent_match)
          select query_id, subject_id, query_taxon_id, subject_taxon_id,
                 evalue_mant, evalue_exp, percent_identity, percent_match
          from apidb.SimilarSequences\@orth500n
          where query_taxon_id in ($taxonList)
            and subject_taxon_id in ($taxonList)
SQL

    $self->runCmd($test, "executeIdSQL.pl --idSQL \"truncate table apidb.SimilarSequences$suffix\" ");

  }
}
