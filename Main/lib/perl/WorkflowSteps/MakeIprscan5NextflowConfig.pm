package ApiCommonWorkflow::Main::WorkflowSteps::MakeIprscan5NextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;
    my $workflowDataDir = $self->getWorkflowDataDir();
    my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
    my $input = join("/", $clusterWorkflowDataDir, $self->getParamValue("input")); 
    my $outputDir = join("/", $clusterWorkflowDataDir, $self->getParamValue("outputDir")); 
    my $configFileName = $self->getParamValue("configFileName");
    my $configPath = join("/", $workflowDataDir,  $self->getParamValue("analysisDir"), $self->getParamValue("configFileName"));
    my $fastaSubsetSize = $self->getParamValue("fastaSubsetSize");
    my $appls = $self->getParamValue("appls");
    my $outputFile = $self->getParamValue("outputFile");
    my $interproscanDatabase = $self->getParamValue("interproscanDatabase");

    if ($undo) {
	$self->runCmd(0,"rm -rf $configPath");
    } else {
	open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";

    print F
"
params {
  input = \"$input\"
  outputDir = \"$outputDir\"
  fastaSubsetSize = $fastaSubsetSize
  appls = \"$appls\" 
  outputFile = \"$outputFile\"
}
process {
  container = 'veupathdb/iprscan5'
}
singularity {
  enabled = true
  autoMounts = true
  runOptions = \"--bind $interproscanDatabase:/opt/interproscan/data\" 
}
";
	close(F);
    }
}

1;
