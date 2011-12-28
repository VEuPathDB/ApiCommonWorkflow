package ApiCommonWorkflow::Main::WorkflowSteps::FixGenomeSourceIdsInBlatResultFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $queryFile = $self->getParamValue('queryFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "replace.pl --old '#' --new '.' --file_or_dir $workflowDataDir/$inputFile";

  if ($undo) {
  } else {
      if ($test) {
	  $self->testInputFile('seqFile', "$workflowDataDir/$inputFile");
      }else{
	  if (-s "$workflowDataDir/$queryFile" || $test) {
	      $self->runCmd($test,$cmd);
	  } else {
	      $self->log("queryFile '$workflowDataDir/$queryFile' is empty.  Doing nothing.");
	  }
      }
  }
}

sub getParamDeclaration {
  return (
	  'inputFile',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

