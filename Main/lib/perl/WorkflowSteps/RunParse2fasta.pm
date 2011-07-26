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

  $outputFile = $pairedEndFile ? $outputFile : $shortSeqsFile;

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {
    if ($test) {
      $self->testInputFile('seqFile', "$workflowDataDir/$shortSeqsFile");
      $self->testInputFile('seqFile', "$workflowDataDir/$pairedEndFile") if $pairedEndFile;
      $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
    } else {
      my $cmd = "parse2fasta.pl $workflowDataDir/$shortSeqsFile";
      $cmd .= " $workflowDataDir/$pairedEndFile" if $pairedEndFile;
      $cmd .= " > $workflowDataDir/$outputFile";
      $self->runCmd($test,$cmd);
    }
  }
}


sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

