package ApiCommonWorkflow::Main::WorkflowSteps::InsertPubChemSubstances;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $fileDir = $self->getParamValue('fileDir');

  my $fileNames = $self->getParamValue('fileNames');

  my $compoundIdsFile = $self->getParamValue('compoundIdsFile');

  my $property = $self->getParamValue('property');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--fileDir $workflowDataDir/$fileDir --fileNames '$fileNames' --compoundIdsFile '$workflowDataDir/$compoundIdsFile'  --property '$property'  ";


  $self->testInputFile('fileDir', "$workflowDataDir/$fileDir");
  $self->testInputFile('fileNames', "$workflowDataDir/$fileDir/$fileNames");

  if ($test) {
    $self->runCmd(0, "echo test > $workflowDataDir/$compoundIdsFile");
  }

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertPubChemSubstances", $args);

}

1;

