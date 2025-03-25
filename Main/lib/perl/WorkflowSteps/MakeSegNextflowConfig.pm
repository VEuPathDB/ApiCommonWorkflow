package ApiCommonWorkflow::Main::WorkflowSteps::MakeSegNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $fastaSubsetSize = 500;

  my $proteinSequenceFile = $self->getParamValue("proteinSequenceFile");
  my $nextflowConfigFile = $self->getParamValue("nextflowConfigFile");
  my $resultsDirectory = $self->getParamValue("resultsDirectory");
  my $outputFileName = $self->getParamValue("outputFileName");
  my $workingDirRelativePath = $self->getParamValue("workingDirRelativePath");

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $clusterServer = $self->getSharedConfig('clusterServer');
  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $executor = $self->getClusterExecutor();

  my $clusterConfigFile = "\$baseDir/conf/${executor}.config";

  if ($undo) {
      $self->runCmd(0, "rm $workflowDataDir/$nextflowConfigFile");
  } else {
      my $nextflowConfig = "$workflowDataDir/$nextflowConfigFile";
      open(F, ">$nextflowConfig") || die "Can't open task prop file '$nextflowConfig' for writing";

      my $proteinSequenceFileInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $proteinSequenceFile);
      my $resultsDirectoryInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $resultsDirectory);

      my $configString = <<NEXTFLOW;
params {
  inputFilePath = "$proteinSequenceFileInNextflowWorkingDirOnCluster"
  outputDir = "$resultsDirectoryInNextflowWorkingDirOnCluster"
  outputFileName = "$outputFileName"
  fastaSubsetSize = $fastaSubsetSize
  seqType = "aa"
}

includeConfig "$clusterConfigFile"

NEXTFLOW

      print F $configString;
      close(F);
  }
}

1;
