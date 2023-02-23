package ApiCommonWorkflow::Main::WorkflowSteps::MakeRepeatMaskerNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
    my $workflowDataDir = $self->getWorkflowDataDir();
    my $inputFilePath = join("/", $clusterWorkflowDataDir, $self->getParamValue("inputFilePath")); 
    my $outputDir = join("/", $clusterWorkflowDataDir, $self->getParamValue("outputDir")); 
    my $configFileName = $self->getParamValue("configFileName");
    my $configPath = join("/", $workflowDataDir,  $self->getParamValue("analysisDir"), $self->getParamValue("configFileName"));
    my $fastaSubsetSize = $self->getParamValue("fastaSubsetSize");
    my $trimDangling = $self->getParamValue("trimDangling");
    my $dangleMax = $self->getParamValue("dangleMax");
    my $rmParams = $self->getParamValue("rmParams");
    my $outputFileName = $self->getParamValue("outputFileName");
    my $errorFileName = $self->getParamValue("errorFileName");
  
    if ($undo) {
	$self->runCmd(0,"rm -rf $configPath");
    } else {
	open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";

    print F
"
params {
  inputFilePath = \"$inputFilePath\"
  fastaSubsetSize = $fastaSubsetSize
  trimDangling = $trimDangling
  dangleMax = $dangleMax
  rmParams = \"$rmParams\"
  outputFileName = \"$outputFileName\"
  errorFileName = \"$errorFileName\"
  outputDir = \"$outputDir\"
}
process {
  container = 'veupathdb/repeatmasker'
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
