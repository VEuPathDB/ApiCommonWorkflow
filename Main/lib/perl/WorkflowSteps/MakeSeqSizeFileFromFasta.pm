
package ApiCommonWorkflow::Main::WorkflowSteps::MakeSeqSizeFileFromFasta;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $outputFile = $self->getParamValue('outputFile');
  my $fastaFile = $self->getParamValue('fastaFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {
      if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
      }
      $self->runCmd($test,"makeSeqSizeFileFromFasta.pl --outFile $workflowDataDir/$outputFile --fasta $workflowDataDir/$fastaFile");
  }
}

1;
