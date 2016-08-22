package ApiCommonWorkflow::Main::WorkflowSteps::TransformRawDataToGenomeCoordinates;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use File::Basename;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');

  my $outputFile =  $self->getParamValue('outputFile');

  my $extDbRlsSpec = $self->getParamValue('chipProbeExtDbRlsSpec');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "TransformRawDataToGenomeCoordinates  --inputFile '$workflowDataDir/$inputFile' --outputFile '$workflowDataDir/$outputFile' --extDbSpec '$extDbRlsSpec'";
    
  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  }else {
    $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
      if ($test){
	  $self->runCmd(0, "echo test> $workflowDataDir/$outputFile");
      }
    $self->runCmd($test, $cmd);
  }

}

1;

