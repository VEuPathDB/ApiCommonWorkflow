package ApiCommonWorkflow::Main::WorkflowSteps::UniDBUnLockComponentProject;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;

use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $projectName = $self->getParamValue('projectName');
  my $databaseInstance = $self->getSharedConfig($projectName . "_instance");

  my $cmd = "lockWorkflowInstance --instance $databaseInstance";

  unless($undo) {
    $cmd .= " --unlock";
  } 

  unless($test) {
    $self->runCmd($test, $cmd);
  }
}

1;


