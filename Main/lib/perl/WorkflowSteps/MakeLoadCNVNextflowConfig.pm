package ApiCommonWorkflow::Main::WorkflowSteps::MakeLoadCNVNextflowConfig;

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
  my $footprintFile = join("/", $workflowDataDir, $self->getParamValue("footprintFile"));
  my $ploidy = $self->getParamValue("ploidy");
  my $taxonId = $self->getParamValue("taxonId");
  my $outputDir = join("/", $workflowDataDir, $self->getParamValue("clusterResultDir"));   

  if ($undo) {
    $self->runCmd(0,"rm -rf $configPath");
  } else {
    open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";

    print F
"
params {
  input = \"$input\"
  outputDir = \"$outputDir\"
  gusConfig = \"\$GUS_HOME/config/gus.config\"
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

