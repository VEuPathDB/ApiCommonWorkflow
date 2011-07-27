package ApiCommonWorkflow::Main::WorkflowSteps::RevertProbeSeqId;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $shortSeqsFile = $self->getParamValue('shortSeqsFile');

  my $inputUniqueFile = $self->getParamValue('inputUniqueFile');

  my $inputNonUniqueFile = $self->getParamValue('inputNonUniqueFile');

  my $outputUniqueFile = $self->getParamValue('outputUniqueFile');

  my $outputNonUniqueFile = $self->getParamValue('outputNonUniqueFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputUniqueFile");
    $self->runCmd(0, "rm -f $workflowDataDir/$outputNonUniqueFile");
  } else {
    if ($test) {
      $self->testInputFile('shortSeqsFile', "$workflowDataDir/$inputUniqueFile");
      $self->testInputFile('inputUniqueFile', "$workflowDataDir/$inputNonUniqueFile");
      $self->testInputFile('inputNonUniqueFile', "$workflowDataDir/$shortSeqsFile");
      $self->runCmd($test,"touch $workflowDataDir/$outputUniqueFile");
      $self->runCmd($test,"touch $workflowDataDir/$outputNonUniqueFile");
    } else {
      $self->runCmd($test,"RevertProbeSeqId --originalShortSeqsFile $workflowDataDir/$shortSeqsFile --inputFile $workflowDataDir/$inputUniqueFile --outputFile $workflowDataDir/$outputUniqueFile");
      $self->runCmd($test,"RevertProbeSeqId --originalShortSeqsFile $workflowDataDir/$shortSeqsFile --inputFile $workflowDataDir/$inputNonUniqueFile --outputFile $workflowDataDir/$outputNonUniqueFile");
    }
  }
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

