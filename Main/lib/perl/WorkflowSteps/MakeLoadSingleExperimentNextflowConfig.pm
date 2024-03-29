package ApiCommonWorkflow::Main::WorkflowSteps::MakeLoadSingleExperimentNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;
  
  my $workflowDataDir = $self->getWorkflowDataDir();
  my $input = join("/", $workflowDataDir, $self->getParamValue("input")); 
  my $configFileName = $self->getParamValue("configFileName");
  my $configPath = join("/", $workflowDataDir,  $self->getParamValue("analysisDir"), $self->getParamValue("configFileName"));
  my $webServicesDir = join("/", $workflowDataDir, $self->getParamValue("webServicesDir"));

  my $executor = $self->getClusterExecutor();
  my $queue = $self->getClusterQueue();

  if ($undo) {
    $self->runCmd(0,"rm -rf $configPath");
  } else {
    open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";

    print F
"
params {
  input = \"$input\"
  webServicesDir = \"$webServicesDir\"
}

singularity {
  enabled = true
  autoMounts = true
}
";
  close(F);
 }
}

1;

