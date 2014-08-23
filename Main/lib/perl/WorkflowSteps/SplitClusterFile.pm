package ApiCommonWorkflow::Main::WorkflowSteps::SplitClusterFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $outputSmallFile = $self->getParamValue('outputSmallFile');
  my $outputBigFile = $self->getParamValue('outputBigFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "splitClusterFile $workflowDataDir/$inputFile $workflowDataDir/$outputSmallFile $workflowDataDir/$outputBigFile";

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputSmallFile");
    $self->runCmd(0, "rm -f $workflowDataDir/$outputBigFile");
  } else {
    $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
      if ($test){
	  $self->runCmd(0,"echo hello > $workflowDataDir/$outputSmallFile");
	  $self->runCmd(0,"echo hello > $workflowDataDir/$outputBigFile");
      }
    $self->runCmd($test,$cmd);
  }
}

1;
