package ApiCommonWorkflow::Main::WorkflowSteps::RunPsipredSingle;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');

  my $psipredPath = $self->getSharedConfig("psipredPath");

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd1 = "mkdir -p $workflowDataDir/result";

  my $cmd2 = "psipredRun --inputFile $inputProteinsFile --outputDir $workflowDataDir/result --psipredPath $psipredPath";

  if ($undo) {
    $self->runCmd(0, "rm -rf $workflowDataDir/result");
  } else {
      if ($test){
	  $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
	  $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
      }else{
	  $self->runCmd($test,$cmd1);
          $self->runCmd($test,$cmd2);
      }
  }
}


sub getParamsDeclaration {
  return ('inputFile',
	  'psipredPath'
	 );
}


sub getConfigDeclaration {
  return (
	  # [name, default, description]
 	 );
}


