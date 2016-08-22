package ApiCommonWorkflow::Main::WorkflowSteps::SnpMergeExperimentSortedTab;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $globInput = $self->getParamValue('globInput');
  my $outputFile = $self->getParamValue('outputFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my @inputs = glob "$workflowDataDir/$globInput";
 

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  }
  else {
    foreach my $inputFile (@inputs) {
	$self->testInputFile('inputFile', "$inputFile");
    }
    if($test) {
      $self->runCmd(0, "echo test > $workflowDataDir/$outputFile");
    } 

    foreach my $inputFile (@inputs) {
	my $cmd = "mergeSortedSnpTab.pl --inputFile $inputFile --cacheFile $workflowDataDir/$outputFile --undoneStrainsFile $workflowDataDir/undoFile --doNotTruncateInputFile";     
	$self->runCmd($test, $cmd);
    }
  }
}

1;
