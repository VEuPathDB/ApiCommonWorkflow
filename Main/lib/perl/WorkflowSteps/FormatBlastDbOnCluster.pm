package ApiCommonWorkflow::Main::WorkflowSteps::FormatBlastDbOnCluster;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


# assumes the input file has had J's and O's converted to X's

sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $vendor = $self->getParamValue('vendor');
  my $type = $self->getParamValue('seqType');

  $self->error("Parameter seqType=$seqType is invalid.  It must be either p or n") unless $seqType eq 'p' || $seqType eq 'n';

  $self->error("Parameter vendor=$vendor is invalid.  It must be either ncbi or wu") unless $vendor eq 'ncbi' || $vendor eq 'wu';

  my $clusterServer = $self->getSharedConfig('clusterServer');
  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();

  my $cmd;
  my $undoCmd;
  if ($vendor eq 'wu') {
    my $blastPath  = $self->getConfig("$clusterServer.wuBlastPathBinCluster");
    $cmd = "$blastPath/xdformat -$seqType  $clusterWorkflowDataDir/$inputFile";
    $undoCmd = "rm -f $clusterWorkflowDataDir/${inputFile}.p*";
  } else {
    my $tf = $seqType eq 'p'? 'T' : 'F';
    my $blastPath  = $self->getConfig("$clusterServer.ncbiBlastBinPathCluster");
    $cmd = "$ncbiBlastPath/formatdb -i $clusterWorkflowDataDir/$inputFile -p $tf";
    $undoCmd = "rm -f $clusterWorkflowDataDir/${inputFile}.x*";
  }

  if ($undo) {
    $self->runCmdOnCluster($test,$undoCmd);
  } else {
      if ($test) {
	  $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
      }else{
	  $self->runCmdOnCluster($test,$cmd);
      }
  }
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	  ['clusterWorkflowDataDir', "", ""],
	 );
}

