package ApiCommonWorkflow::Main::WorkflowSteps::RunSignalP;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $proteinsFile = $self->getParamValue('proteinsFile');
  my $outputFile = $self->getParamValue('outputFile');
  my $options = $self->getParamValue('options');

  my $binPath = $self->getConfig('binPath');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "runSignalP --binPath $binPath  --options '$options' --seqFile $workflowDataDir/$proteinsFile --outFile $workflowDataDir/$outputFile";

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {
      if ($test) {
	  $self->testInputFile('proteinsFile', "$workflowDataDir/$proteinsFile");
	  $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
      }else{
	  $self->runCmd($test,$cmd);
      }
  }
}

sub getParamDeclaration {
  return (
	  'proteinsFile',
	  'outputFile',
	  'options',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	  ['binPath', "", ""],
	 );
}


