package ApiCommonWorkflow::Main::WorkflowSteps::MakeLoadSingleExperimentNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $input = join("/", $clusterWorkflowDataDir, $self->getParamValue("input")); 
  my $configFileName = $self->getParamValue("configFileName");
  my $configPath = join("/", $self->getWorkflowDataDir(),  $self->getParamValue("analysisDir"), $self->getParamValue("configFileName"));
  my $extDbRlsSpec = $self->getParamValue("extDbRlsSpec");
  my $genomeExtDbRlsSpec = $self->getParamValue("genomeExtDbRlsSpec");
  my $webServicesDir = join("/", $clusterWorkflowDataDir, $self->getParamValue("webServicesDir"));

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
  extDbRlsSpec = \'$extDbRlsSpec\'
  genomeExtDbRlsSpec = \"$genomeExtDbRlsSpec\"
  webServicesDir = \"$webServicesDir\"
}

process {
  executor = \'lsf\'
  queue = \'eupathdb\'
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

