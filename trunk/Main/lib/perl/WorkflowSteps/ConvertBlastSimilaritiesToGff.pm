package ApiCommonWorkflow::Main::WorkflowSteps::ConvertBlastSimilaritiesToGff;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $gffOutputFile = $self->getParamValue('gffOutputFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "blastToGff.pl --blastInput $workflowDataDir/$inputFile --outputFile $workflowDataDir/$gffOutputFile";
  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$gffOutputFile");
  } else {
      if ($test) {
	  $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
	  $self->runCmd(0,"echo test > $workflowDataDir/$gffOutputFile");
      }else{
	  $self->runCmd($test,$cmd);
      }
  }
}

sub getParamDeclaration {
  return (
	  'inputFile',
	  'gffOutputFile',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

