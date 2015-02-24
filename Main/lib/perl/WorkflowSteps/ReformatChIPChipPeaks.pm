package ApiCommonWorkflow::Main::WorkflowSteps::ReformatChIPChipPeaks;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');

  my $outputFile =  $self->getParamValue('outputFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "reformatPeaks.pl  --inputFile $workflowDataDir/$inputFile --outputFile $workflowDataDir/$outputFile";

  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  }else {
      $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
      if ($test){
	  $self->runCmd(0, "echo test > $workflowDataDir/$outputFile");
      }
      $self->runCmd($test, $cmd);
  }

}

1;
