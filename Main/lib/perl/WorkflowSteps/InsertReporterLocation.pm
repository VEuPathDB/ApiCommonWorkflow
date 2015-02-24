package ApiCommonWorkflow::Main::WorkflowSteps::InsertReporterLocation;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $bamFile = $self->getParamValue('bamFile');

  my $platformExtDbSpec = $self->getParamValue('platformExtDbSpec');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--inputFile $workflowDataDir/$bamFile  --platformExtDbSpec '$platformExtDbSpec'";

  $self->testInputFile('inputDir', "$workflowDataDir/$bamFile");

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertReporterLocation", $args);
}

1;
