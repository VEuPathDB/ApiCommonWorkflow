package ApiCommonWorkflow::Main::WorkflowSteps::PatchSiRNABySql;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $dataDir = $self->getParamValue('dataDir');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "patchSiRNABySql";
  if ($undo) {
  } else {
      if ($test) {
      }else{
	  $self->runCmd($test,$cmd);
      }
  }
}

sub getParamDeclaration {
  return (
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

