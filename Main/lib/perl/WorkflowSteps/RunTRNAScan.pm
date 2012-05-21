package ApiCommonWorkflow::Main::WorkflowSteps::RunTRNAScan;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $seqFile = $self->getParamValue('seqFile');
  my $outputFile = $self->getParamValue('outputFile');

  my $binPath = $self->getConfig('tRNAscanBinDir');
  my $workflowDataDir = $self->getWorkflowDataDir();

  $self->error("Output file '$workflowDataDir/$outputFile' already exists") if !$undo && -e "$workflowDataDir/$outputFile";

  my $cmd = "$binPath/tRNAscan-SE -o $workflowDataDir/$outputFile $workflowDataDir/$seqFile";

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {
      if ($test) {
	  $self->testInputFile('proteinsFile', "$workflowDataDir/$seqFile");
	  $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
      }
      $self->runCmd($test,$cmd);
  }
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	  ['binPath', "", ""],
	 );
}

