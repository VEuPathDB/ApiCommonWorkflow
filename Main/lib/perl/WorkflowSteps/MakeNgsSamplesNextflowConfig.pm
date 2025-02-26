package ApiCommonWorkflow::Main::WorkflowSteps::MakeNgsSamplesNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  #NOTE: the subset size here would run "X" number of genomic sequences at a time on the cluster (chromosomes or contigs)
  my $fastaSubsetSize = 5;

  my $finalDir = $self->getParamValue("finalDirectory");
  my $resultsDirectory = $self->getParamValue("resultsDirectory");
  my $analysisDirectory = $self->getParamValue("analysisDirectory");

  my $nextflowConfigFile = $self->getParamValue("nextflowConfigFile");
  my $sampleSheetName = $self->getParamValue("sampleSheetName");
  my $fromSRA = $self->getBooleanParamValue("fromSRA") ? "true" : "false";

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $workingDirRelativePath = $self->getParamValue("workingDirRelativePath");
  my $digestedFinalDirPath = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $finalDir);
  my $digestedAnalysisDirPath = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $analysisDirectory);
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
  input = "$digestedFinalDirPath"
  samplesheetName = "$sampleSheetName"
  fromSra = $fromSRA
  outputDir = "$digestedOutputDir"
}

process {
  maxForks = 2
}

includeConfig "$clusterConfigFile"

apptainer.registry   = 'quay.io'
docker.registry      = 'quay.io'
podman.registry      = 'quay.io'
singularity.registry = 'quay.io'

workDir = "$digestedAnalysisDirPath/ngs-samples-work"

NEXTFLOW

      print F $configString;
      close(F);
  }
}

1;
