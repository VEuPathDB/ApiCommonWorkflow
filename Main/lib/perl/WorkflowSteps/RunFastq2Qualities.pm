package ApiCommonWorkflow::Main::WorkflowSteps::RunFastq2Qualities;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $shortSeqsFile = $self->getParamValue('shortSeqsFile');

  my $pairedEndFile = $self->getParamValue('pairedEndFile');

  my $outputFile = $self->getParamValue('outputFile');

  my $workflowDataDir = $self->getWorkflowDataDir();


    if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {
    $self->testInputFile('seqFile', "$workflowDataDir/$shortSeqsFile");
    $self->testInputFile('seqFile', "$workflowDataDir/$pairedEndFile") if $pairedEndFile;

    if ($test) {
      $self->runCmd(0, "echo test > $workflowDataDir/$outputFile");
    }
    my $cmd = "fastq2qualities.pl $workflowDataDir/$shortSeqsFile";
    $cmd .= " $workflowDataDir/$pairedEndFile" if $pairedEndFile;
    $cmd .= " > $workflowDataDir/$outputFile";
    $self->runCmd($test,$cmd);
    
  }
}

1;
