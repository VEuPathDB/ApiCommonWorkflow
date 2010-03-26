package ApiCommonWorkflow::Main::WorkflowSteps::MirrorToComputeCluster;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use File::Basename;

sub run {
  my ($self, $test, $undo) = @_;

  # get param values
  my $fileOrDirToMirror = $self->getParamValue('fileOrDirToMirror');

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();

  my ($filename, $relativeDir) = fileparse($fileOrDirToMirror);

  if($undo){
      $self->runCmdOnCluster(0, "rm -fr $clusterWorkflowDataDir/$fileOrDirToMirror");
  }else{

      $self->copyToCluster("$workflowDataDir/$relativeDir",
			   $filename,
			   "$clusterWorkflowDataDir/$relativeDir");
  }
}

sub getParamDeclaration {
  return (
	  'fileOrDirToMirror',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

