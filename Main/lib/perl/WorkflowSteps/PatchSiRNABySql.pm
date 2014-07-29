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
    $self->runCmd($test,$cmd);
  }
}

1;
