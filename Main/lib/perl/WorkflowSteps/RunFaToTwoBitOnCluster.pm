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

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();

  my $outputFile = $inputFastaFile;
  $outputFile =~ s/\..*$/\.2bit/;

  my $cmd = "faToTwoBit $clusterWorkflowDataDir/$inputFastaFile $clusterWorkflowDataDir/$outputFile";

  if ($undo) {
    $self->runCmdOnCluster(0,"rm $clusterWorkflowDataDir/$outputFile");
  } else {
      if ($test) {
	  $self->testInputFile('inputFastaFile', "$workflowDataDir/$inputFastaFile");
	  $self->runCmd(0, "echo test > $clusterWorkflowDataDir/$outputFile");
      }else{
	  $self->runCmdOnCluster($test,$cmd);
      }
  }
}

sub getParamDeclaration {
  return (
     'inputFastaFile',
    );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	  ['clusterWorkflowDataDir', "", ""],
	 );
}
