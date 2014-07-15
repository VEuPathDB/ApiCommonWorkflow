package ApiCommonWorkflow::Main::WorkflowSteps::RunLowComplexityFilter;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $seqFile = $self->getParamValue('seqFile');
  my $outputFile = $self->getParamValue('outputFile');
  my $filterType = $self->getParamValue('filterType');
  my $options = $self->getParamValue('options');

  my $blastDir = $self->getConfig('wuBlastPath');

  my $filter = "$blastDir/filter/$filterType";

  my $workflowDataDir = $self->getWorkflowDataDir();

  if (!$test && !$undo){
    $self->error("Sequence file '$workflowDataDir/$seqFile' does not exist or is empty") unless (-s "$workflowDataDir/$seqFile");
  }

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {
    $self->testInputFile('seqFile', "$workflowDataDir/$seqFile");
    if ($test) {
      $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
    }
    $self->runCmd($test,"$filter $workflowDataDir/$seqFile $options > $workflowDataDir/$outputFile");
  }
}

1;
