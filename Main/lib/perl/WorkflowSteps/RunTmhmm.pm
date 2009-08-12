package ApiCommonWorkflow::Main::WorkflowSteps::RunTmhmm;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $proteinsFile = $self->getParamValue('proteinsFile');
  my $outputFile = $self->getParamValue('outputFile');

  my $binPath = $self->getConfig('binPath');

  my $localDataDir = $self->getLocalDataDir();

  my $cmd = "runTMHMM -binPath $binPath -short -seqFile $localDataDir/$proteinsFile -outFile $localDataDir/$outputFile";

  if ($undo) {
    $self->runCmd(0, "rm -f $localDataDir/$outputFile");
  } else {
      if ($test) {
	  $self->testInputFile('proteinsFile', "$localDataDir/$proteinsFile");
	  $self->runCmd(0,"echo test > $localDataDir/$outputFile");
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

