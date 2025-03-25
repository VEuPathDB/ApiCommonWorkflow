package ApiCommonWorkflow::Main::WorkflowSteps::MakeTrfConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $fastaSubsetSize = 10;

  my $genomicSequenceFile = $self->getParamValue("genomicSequenceFile");
  my $nextflowConfigFile = $self->getParamValue("nextflowConfigFile");
  my $resultsDirectory = $self->getParamValue("resultsDirectory");
  my $outputFileName = $self->getParamValue("outputFileName");
  my $args = $self->getParamValue("args");

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $workingDirRelativePath = $self->getParamValue("workingDirRelativePath");
  my $digestedInputFilePath = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $genomicSequenceFile);
  my $digestedOutputDir = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $resultsDirectory);

  my $clusterServer = $self->getSharedConfig('clusterServer');
  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $executor = $self->getClusterExecutor();

  my $clusterConfigFile = "\$baseDir/conf/${executor}.config";

  if ($undo) {
      $self->runCmd(0, "rm $workflowDataDir/$nextflowConfigFile");
  } else {
      my $nextflowConfig = "$workflowDataDir/$nextflowConfigFile";
      open(F, ">$nextflowConfig") || die "Can't open task prop file '$nextflowConfig' for writing";

      my $configString = <<NEXTFLOW;
params {
  inputFilePath = "$digestedInputFilePath"
  outputDir = "$digestedOutputDir"
  outputFileName = "$outputFileName"
  args = "$args"
  fastaSubsetSize = $fastaSubsetSize
}

includeConfig "$clusterConfigFile"

NEXTFLOW

      print F $configString;
      close(F);
  }
}

1;
