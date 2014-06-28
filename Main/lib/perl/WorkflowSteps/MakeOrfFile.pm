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
    $self->testInputFile('seqFile', "$workflowDataDir/$seqFile");
      if ($test) {
	  $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
      }
    $self->runCmd($test,$cmd);

  }
}

1;

