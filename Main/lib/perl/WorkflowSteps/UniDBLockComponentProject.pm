package ApiCommonWorkflow::Main::WorkflowSteps::UniDBLockComponentProject;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;

use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $databaseInstance = $self->getParamValue('databaseInstance');

  my $cmd = "lockWorkflowInstance --instance $databaseInstance";

  if($undo) {
    $cmd =. " --unlock";
  } 

  unless($test) {
    $self->runCmd($test, $cmd);
  }
}

1;


