package ApiCommonWorkflow::Main::WorkflowSteps::MakeOrfFinderConfig;

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
  my $minPepLength = $self->getParamValue("minPepLength");
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
      my $genomicSequenceFileInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $genomicSequenceFile);
      my $resultsDirectoryInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $resultsDirectory);

      my $configString = <<NEXTFLOW;
params {
  inputFilePath = "$genomicSequenceFileInNextflowWorkingDirOnCluster"
  outputDir = "$resultsDirectoryInNextflowWorkingDirOnCluster"
  outputFileName = "$outputFileName"
  minPepLength = $minPepLength
  fastaSubsetSize = $fastaSubsetSize
}

includeConfig "$clusterConfigFile"

NEXTFLOW

      print F $configString;
      close(F);
  }
}

1;
