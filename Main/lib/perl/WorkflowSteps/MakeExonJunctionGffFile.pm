package ApiCommonWorkflow::Main::WorkflowSteps::MakeExonJunctionGffFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use File::Basename;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');

  my $sampleName = $self->getParamValue('sampleName');

  my $outputFile =  $self->getParamValue('outputFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "makeExonJunctionGffFile  --inputFile '$workflowDataDir/$inputFile' --sampleName '$sampleName' --outputFile '$workflowDataDir/$outputFile'";
    
  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  }else {
      if ($test){
	  $self->runCmd(0, "echo test> $workflowDataDir/$outputFile");
      }
      $self->runCmd($test, $cmd);
  }

}

1;
