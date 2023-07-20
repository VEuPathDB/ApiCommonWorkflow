package ApiCommonWorkflow::Main::WorkflowSteps::MakePsiPredNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
    my $inputFilePath = join("/", $clusterWorkflowDataDir, $self->getParamValue("inputFilePath")); 
    my $outputDir = join("/", $clusterWorkflowDataDir, $self->getParamValue("outputDir")); 
    my $configFileName = $self->getParamValue("configFileName");
    my $configPath = join("/", $workflowDataDir,  $self->getParamValue("analysisDir"), $self->getParamValue("configFileName"));
  
    if ($undo) {
	$self->runCmd(0,"rm -rf $configPath");
    } else {
	open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";

    print F
"
params {
  inputFilePath = \"$inputFilePath\"
  outputDir = \"$outputDir\"
}
process {
  container = 'veupathdb/psipred:latest'
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
