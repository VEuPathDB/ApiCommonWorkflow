package ApiCommonWorkflow::Main::WorkflowSteps::LoadWebreadyTable;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $psqlDirName = $self->getParamValue('psqlDirName');
  my $tableName = $self->getParamValue('tableName');
  my $projectId = $self->getParamValue('projectName');
  my $gusConfigFile = $self->getParamValue('gusConfigFile');

  my $schema = $self->getSharedConfig('webreadySchema');

  $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $psqlDirPath = "$ENV{GUS_HOME}/lib/psql/webready/$psqlDirName";

  my $args = "--mode standard --psqlDirPath $psqlDirPath --tableName $tableName --schema $schema --projectId $projectId --taxonId 1";

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::LoadDenormalizedTable", $args);

}

1;

