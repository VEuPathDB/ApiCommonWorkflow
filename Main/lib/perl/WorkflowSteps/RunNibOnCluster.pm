package ApiCommonWorkflow::Main::WorkflowSteps::RunNibOnCluster;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use File::Basename;

####################################################################################################################
###convert from Fasta to .nib format, which is a somewhat less dense randomly accessible format that predates .2bit.  
###Note each .nib file can only contain a single sequence.
####################################################################################################################

sub run {
  my ($self, $test, $undo) = @_;

  my $inputTargetListFile = $self->getParamValue('inputTargetListFile');

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $dirname = dirname($inputTargetListFile);

  my $cmd = "runFaToNib --filesFile $clusterWorkflowDataDir/$inputTargetListFile";

  if ($undo) {
    #$self->runCmdOnCluster(0,"rm -r $clusterWorkflowDataDir/$dirname/nib/");
  } else {
    $self->testInputFile('inputTargetListFile', "$workflowDataDir/$inputTargetListFile");
      if ($test) {
	  $self->runCmdOnCluster(0,"mkdir $clusterWorkflowDataDir/$dirname/nib") unless $undo;
      }
    $self->runCmdOnCluster($test,$cmd);
  }
}

1;
