package ApiCommonWorkflow::Main::WorkflowSteps::RunFaToTwoBitOnCluster;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use File::Basename;

####################################################################################################################
###convert from Fasta to .2bit.
###the fasta file can contain many sequences
####################################################################################################################

sub run {
  my ($self, $test, $undo) = @_;

  my $inputFastaFile = $self->getParamValue('inputFastaFile');
  my $output2bitFile = $self->getParamValue('output2BitFile');

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();

  my $clusterServer = $self->getSharedConfig('clusterServer');
  my $clusterQueue = $self->getSharedConfig("$clusterServer.clusterQueue");

  my $cmd = "bsub -q $clusterQueue faToTwoBit $clusterWorkflowDataDir/$inputFastaFile $clusterWorkflowDataDir/$output2bitFile";

  if ($undo) {
    $self->runCmdOnClusterTransferServer(0,"rm $clusterWorkflowDataDir/$output2bitFile");
  } else {
    $self->testInputFile('inputFastaFile', "$workflowDataDir/$inputFastaFile");
      if ($test) {
	  $self->runCmdOnClusterTransferServer(0, "echo test > $clusterWorkflowDataDir/$output2bitFile");
      }
    $self->runCmdOnCluster($test,$cmd);
  }
}

1;
