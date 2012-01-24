package ApiCommonWorkflow::Main::WorkflowSteps::RunPsipredSingle;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');

  my $outputDir = $self->getParamValue('outputDir');

  my $psipredPath = $self->getConfig("psipredPath");

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd1 = "mkdir -p $workflowDataDir/$outputDir";

  my $cmd2 = "psipredRun --inputFile $workflowDataDir/$inputFile --outputDir $workflowDataDir/$outputDir --psipredPath $psipredPath";

  if ($undo) {
    $self->runCmd(0, "rm -rf $workflowDataDir/$outputDir");
  } else {
      if ($test){
	  $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
	  $self->runCmd(0,"mkdir -p $workflowDataDir/$outputDir");
      }else{
	  $self->runCmd($test,$cmd1);
          $self->runCmd($test,$cmd2);
      }
  }
}



sub getConfigDeclaration {
  return (
	  # [name, default, description]
 	 );
}


