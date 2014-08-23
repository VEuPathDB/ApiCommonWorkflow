package ApiCommonWorkflow::Main::WorkflowSteps::ExcludeMultiExonHits;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputUniqueFile = $self->getParamValue('inputUniqueFile');

  my $inputNonUniqueFile = $self->getParamValue('inputNonUniqueFile');

  my $outputUniqueFile = $self->getParamValue('outputUniqueFile');

  my $outputNonUniqueFile = $self->getParamValue('outputNonUniqueFile');

  my $excludeMultiExonsIf = $self->getBooleanParamValue('excludeMultiExonsIf');

  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputUniqueFile");
    $self->runCmd(0, "rm -f $workflowDataDir/$outputNonUniqueFile");

  } else {
    $self->testInputFile('inputUniqueFile', "$workflowDataDir/$inputUniqueFile");
    $self->testInputFile('inputNonUniqueFile', "$workflowDataDir/$inputNonUniqueFile");

    if ($test) {
      $self->runCmd(0,"echo test > $workflowDataDir/$outputUniqueFile");
      $self->runCmd(0,"echo test > $workflowDataDir/$outputNonUniqueFile");
    }
    my $command = ($excludeMultiExonsIf)? "grep -v ','" : "cat";
    $self->runCmd($test,"$command $workflowDataDir/$inputUniqueFile > $workflowDataDir/$outputUniqueFile");
    $self->runCmd($test,"$command $workflowDataDir/$inputNonUniqueFile > $workflowDataDir/$outputNonUniqueFile");

  }
}

1;
