package ApiCommonWorkflow::Main::WorkflowSteps::InsertPubChemCompounds;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $fileDir = $self->getParamValue('fileDir');

  my $fileNames = $self->getParamValue('fileNames');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--fileDir $workflowDataDir/$fileDir --fileNames '$fileNames' ";

  $self->testInputFile('fileDir', "$workflowDataDir/$fileDir");
  $self->testInputFile('fileNames', "$workflowDataDir/$fileDir/$fileNames");

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertPubChemCompounds", $args);

}

1;
