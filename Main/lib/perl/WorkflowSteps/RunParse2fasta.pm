package ApiCommonWorkflow::Main::WorkflowSteps::RunParse2fasta;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $shortSeqsFile = $self->getParamValue('inputShortSeqsFile');

  my $pairedEndFile = $self->getParamValue('pairedEndFile');

  my $outputFile = $self->getParamValue('outputShortSeqsFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {
    $self->testInputFile('shortSeqsFile', "$workflowDataDir/$shortSeqsFile");
    $self->testInputFile('pairedEndFile', "$workflowDataDir/$pairedEndFile") if $pairedEndFile;

    if ($test) {
      $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
    }
    my $cmd = "parse2fasta.pl $workflowDataDir/$shortSeqsFile";
    $cmd .= " $workflowDataDir/$pairedEndFile" if $pairedEndFile;
    $cmd .= " > $workflowDataDir/$outputFile";
    $self->runCmd($test,$cmd);
  }
}


1;
