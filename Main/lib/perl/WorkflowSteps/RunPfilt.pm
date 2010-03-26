package ApiCommonWorkflow::Main::WorkflowSteps::RunPfilt;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $inputFile = $self->getParamValue('inputFile');
  my $outputFile = $self->getParamValue('outputFile');

  # get step properties
  my $psipredPath = $self->getConfig('psipredPath');

  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {
      if ($test) {
	  $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
	  $self->runCmd(0, "echo test > $workflowDataDir/$outputFile");
      }else{
	  $self->runCmd($test, "$psipredPath/pfilt $workflowDataDir/$inputFile > $workflowDataDir/$outputFile");
      }
  }
}

sub getParamsDeclaration {
  return (
          'inputFile',
          'outputFile',
         );
}

sub getConfigDeclaration {
  return (
         # [name, default, description]
          ['psipredPath', '', ''],
         );
}

