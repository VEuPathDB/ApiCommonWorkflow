package ApiCommonWorkflow::Main::WorkflowSteps::RunTmhmm;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $proteinsFile = $self->getParamValue('proteinsFile');
  my $outputFile = $self->getParamValue('outputFile');

  my $binPath = $self->getConfig('binPath');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "runTMHMM -binPath $binPath -short -seqFile $workflowDataDir/$proteinsFile -outFile $workflowDataDir/$outputFile";

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
    );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	  ['binPath', "", ""],
	 );
}

