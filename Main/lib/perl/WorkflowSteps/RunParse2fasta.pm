package ApiCommonWorkflow::Main::WorkflowSteps::RunParse2fasta;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $shortSeqsFile = $self->getParamValue('shortSeqsFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

    if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$shortSeqsFile");
    $self->runCmd(0, "mv $workflowDataDir/$shortSeqsFile.org $workflowDataDir/$shortSeqsFile");
  } else {
      if ($test) {
	  $self->testInputFile('seqFile', "$workflowDataDir/$shortSeqsFile");
      }else{
	  $self->runCmd($test,"mv $workflowDataDir/$shortSeqsFil $workflowDataDir/$shortSeqsFile.org");
	  $self->runCmd($test,"parse2fasta.pl $workflowDataDir/$shortSeqsFile.org > $workflowDataDir/$shortSeqsFile");
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

