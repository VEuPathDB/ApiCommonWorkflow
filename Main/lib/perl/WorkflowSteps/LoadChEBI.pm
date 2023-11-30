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
     #$self->runCmd(0, "echo exit|sqlplus $chebiLogin/$chebiPassword\@$gusInstance \@$dataDir/disable_constraints.sql");
     #$self->runCmd(0, "sqlplus $chebiLogin/$chebiPassword\@$gusInstance \@$ENV{GUS_HOME}/lib/sql/apidbschema/dropChebiTables.sql");
  } else {
    for my $sqlFile (@files) {
      $self->runCmd($test, "psql --echo-all -v ON_ERROR_STOP=1 -c 'SET ROLE GUS_W' -f $dataDir/$sqlFile $connectionString");
    }
  }
}

1;
