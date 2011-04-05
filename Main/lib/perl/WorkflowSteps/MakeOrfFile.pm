package ApiCommonWorkflow::Main::WorkflowSteps::MakeOrfFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $seqFile = $self->getParamValue('seqFile');
  my $minPepLength = $self->getParamValue('minPepLength');
  my $outputFile = $self->getParamValue('outputFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = <<"EOF";
orfFinder --dataset  $workflowDataDir/$seqFile \\
--minPepLength $minPepLength \\
--outFile $workflowDataDir/$outputFile
EOF

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {
      if ($test) {
	  $self->testInputFile('seqFile', "$workflowDataDir/$seqFile");
	  $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
      }else{
	  $self->runCmd($test,$cmd);
      }
  }
}

sub getParamDeclaration {
  return (
	  'inputFile',
	  'minPepLength',
	  'outputFile',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

