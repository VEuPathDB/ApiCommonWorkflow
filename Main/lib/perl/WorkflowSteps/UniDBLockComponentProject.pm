package ApiCommonWorkflow::Main::WorkflowSteps::UniDBLockComponentProject;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;

use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $projectName = $self->getParamValue('projectName');

  my $componentProps = $self->getSharedConfig($projectName . "_PROPS");
  my $componentPropsHash = eval $componentProps;
  $self->error("error in PROPS object in stepsShared.prop for $projectName") if($@);
  my $databaseInstance = $componentPropsHash->{instance};
  unless($databaseInstance) {
    $self->error("instance must be specified in PROPS object in stepsShared.prop for $projectName");
  }
  
  my $cmd = "lockWorkflowInstance --instance $databaseInstance";

  if($undo) {
    $cmd .= " --unlock";
  } 

  unless($test) {
    $self->runCmd($test, $cmd);
  }
}

1;


