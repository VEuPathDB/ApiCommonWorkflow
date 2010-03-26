package ApiCommonWorkflow::Main::WorkflowSteps::MapSageTagsToNaSequences;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $genomicSeqsFile = $self->getParamValue('genomicSeqsFile');
  my $sageTagFile = $self->getParamValue('sageTagFile');
  my $outputFile = $self->getParamValue('outputFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "tagToSeq.pl $workflowDataDir/$genomicSeqsFile $workflowDataDir/$sageTagFile 2> $workflowDataDir/$outputFile";
  if ($test) {
    $self->testInputFile('genomicSeqsFile', "$workflowDataDir/$genomicSeqsFile");
    $self->testInputFile('sageTagFile', "$workflowDataDir/$sageTagFile");
    $self->runCmd(0, "echo test > $workflowDataDir/$outputFile");
  }

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {
      if ($test) {
	  $self->testInputFile('genomicSeqsFile', "$workflowDataDir/$genomicSeqsFile");
	  $self->testInputFile('sageTagFile', "$workflowDataDir/$sageTagFile");
	  $self->runCmd(0, "echo test > $workflowDataDir/$outputFile");
      }else{
	  $self->runCmd($test, $cmd);
      }
  }

}

sub getParamsDeclaration {
  return (
          'genomicSeqsFile',
          'outputFile',
          'sageTagFile',
         );
}

sub getConfigDeclaration {
  return (
         # [name, default, description]
         # ['', '', ''],
         );
}


