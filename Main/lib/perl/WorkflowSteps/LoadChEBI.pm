package ApiCommonWorkflow::Main::WorkflowSteps::LoadChEBI;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $login = $self->getGusDatabaseLogin();
  my $password = $self->getGusDatabasePassword();
  my $hostname = $self->getGusDatabaseHostname();
  my $databaseName = $self->getGusDatabaseName();
  my $connectionString = "postgresql://$login:$password\@$hostname/$databaseName";

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $dataDir = $workflowDataDir . "/" . $self->getParamValue('dataDir'). "/" . $self->getParamValue('datasetName'). "/final" ;

  my @files = qw(
    compounds.sql
    chemical_data.sql
    comments.sql
    compound_origins.sql
    database_accession.sql
    names.sql
    references.sql
    relation.sql
    structures.sql
  );

  if ($undo) {
    $self->runCmd($test, "echo 'SET ROLE GUS_W; SET SEARCH_PATH TO chebi; TRUNCATE TABLE chebi.compounds CASCADE;' | psql --echo-all -v ON_ERROR_STOP=1 $connectionString");
  } else {
    for my $sqlFile (@files) {
      # psql 9 doesn't support multiple commands/files. doing workaround.
      # $self->runCmd($test, "psql --echo-all --single-transaction -v ON_ERROR_STOP=1 -c 'SET ROLE GUS_W' -c 'SET SEARCH_PATH TO chebi' -f $dataDir/$sqlFile $connectionString --single-transaction");
      $self->logErr( "Running $sqlFile\n");
      $self->runCmd($test, "echo 'BEGIN; SET ROLE GUS_W; SET SEARCH_PATH TO chebi; \\i $dataDir/$sqlFile \\\\ END;' | psql -v ON_ERROR_STOP=1 $connectionString");
      $self->logErr( "Finished running $sqlFile\n");
    }
  }
}

1;
