package ApiCommonWorkflow::Main::WorkflowSteps::RevertProbeSeqId;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $shortSeqsFile = $self->getParamValue('shortSeqsFile');

  my $originalShortSeqsFile = $self->getParamValue('originalShortSeqsFile');

  my $inputUniqueFile = $self->getParamValue('inputUniqueFile');

  my $inputNonUniqueFile = $self->getParamValue('inputNonUniqueFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

    if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$inputUniqueFile");
    $self->runCmd(0, "rm -f $workflowDataDir/$inputNonUniqueFile");
    $self->runCmd(0, "mv $workflowDataDir/$inputUniqueFile.org $workflowDataDir/$inputUniqueFile");
    $self->runCmd(0, "mv $workflowDataDir/$inputNonUniqueFile.org $workflowDataDir/$inputNonUniqueFile");
  } else {
      if ($test) {
	  $self->testInputFile('seqFile', "$workflowDataDir/$shortSeqsFile");
	  $self->testInputFile('seqFile', "$workflowDataDir/$originalShortSeqsFile");
	  $self->testInputFile('seqFile', "$workflowDataDir/$inputUniqueFile");
	  $self->testInputFile('seqFile', "$workflowDataDir/$inputNonUniqueFile");
      }else{
	  $self->runCmd($test,"mv $workflowDataDir/$inputUniqueFile $workflowDataDir/$inputUniqueFile.org");
	  $self->runCmd($test,"mv $workflowDataDir/$inputNonUniqueFile $workflowDataDir/$inputNonUniqueFile.org");
	  $self->runCmd($test,"RevertProbeSeqId --originalShortSeqsFile $workflowDataDir/$originalShortSeqsFile --inputFile $workflowDataDir/$inputUniqueFile.org --outputFile $workflowDataDir/$inputUniqueFile");
	  $self->runCmd($test,"RevertProbeSeqId --originalShortSeqsFile $workflowDataDir/$originalShortSeqsFile --inputFile $workflowDataDir/$inputNonUniqueFile.org --outputFile $workflowDataDir/$inputNonUniqueFile");
      }
  }
}

sub getParamDeclaration {
  return (
	  'shortSeqsFile',
	  'originalShortSeqsFile',
	  'inputUniqueFile',
	  'inputNonUniqueFile',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

