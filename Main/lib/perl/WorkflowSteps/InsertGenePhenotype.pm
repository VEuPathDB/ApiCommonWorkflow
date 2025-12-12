package ApiCommonWorkflow::Main::WorkflowSteps::InsertGenePhenotype;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $extDbName = $self->getParamValue('extDbName');
  my $extDbVersion = $self->getParamValue('extDbVersion');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--file $workflowDataDir/$inputFile --extDbRlsSpec '${extDbName}|${extDbVersion}'";

  $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertGenePhenotype", $args);
}

1;
