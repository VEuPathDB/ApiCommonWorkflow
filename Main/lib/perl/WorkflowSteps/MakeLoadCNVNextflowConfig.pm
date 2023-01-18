package ApiCommonWorkflow::Main::WorkflowSteps::MakeLoadCNVNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $input = join("/", $clusterWorkflowDataDir, $self->getParamValue("input"));
  my $gusConfig = $self->getParamValue("gusConfig");
  my $configFileName = $self->getParamValue("configFileName");
  my $configPath = join("/", $self->getWorkflowDataDir(),  $self->getParamValue("analysisDir"), $self->getParamValue("configFileName"));
  my $footprintFile = join("/", $clusterWorkflowDataDir, $self->getParamValue("footprintFile"));
  my $ploidy = $self->getParamValue("ploidy");
  my $taxonId = $self->getParamValue("taxonId");
  my $outputDir = join("/", $clusterWorkflowDataDir, $self->getParamValue("clusterResultDir"));   

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
  outputDir = \"$outputDir\"
  gusConfig = \"$gusConfig\"
  footprintFile = \"$footprintFile\"
  ploidy = $ploidy
  taxonId = \"$taxonId\"
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

