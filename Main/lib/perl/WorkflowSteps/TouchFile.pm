package ApiCommonWorkflow::Main::WorkflowSteps::TouchFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $fileName = $self->getParamValue('fileName');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "touch $workflowDataDir/$fileName";

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$fileName");
  } else {
    $self->runCmd($test, $cmd);
  }
}

1;
