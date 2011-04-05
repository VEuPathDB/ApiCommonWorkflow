package ApiCommonWorkflow::Main::WorkflowSteps::RunNibOnCluster;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $outputDir = $self->getParamValue('outputDir');

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();

  my $cmd = "runFaToNib --filesFile $clusterWorkflowDataDir/$inputFile";

  if ($undo) {
    $self->runCmdOnCluster(0,"rm -f $clusterWorkflowDataDir/$outputDir/test.nib");
  } else {
      if ($test) {
	  $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
	  $self->testInputFile('outputDir', "$workflowDataDir/$outputDir");
	  $self->runCmdOnCluster(0,"echo test > $clusterWorkflowDataDir/$outputDir/test.nib") unless $undo;
      }else{
	  $self->runCmdOnCluster($test,$cmd);
      }
  }
}

sub getParamDeclaration {
  return (
     'inputFile',
     'outputDir',
    );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	  ['clusterWorkflowDataDir', "", ""],
	 );
}

