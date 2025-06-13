package ApiCommonWorkflow::Main::WorkflowSteps::MakeGenomicArrayExperimentNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $maxForks = 5;

  my $inputDir = $self->getParamValue("inputDir");
  my $nextflowConfigFile = $self->getParamValue("nextflowConfigFile");
  my $resultsDirectory = $self->getParamValue("resultsDirectory");

  my $probesBam = $self->getParamValue("probesBam");
  my $seqSizes = $self->getParamValue("seqSizes");

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $workingDirRelativePath = $self->getParamValue("workingDirRelativePath");

  my $digestedInputDirectory = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $inputDir);
  my $digestedOutputDir = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $resultsDirectory);
  my $digestedProbesBam = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $probesBam);
  my $digestedSeqSizes = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $seqSizes);


  my $sampleSheetFileName = $self->getParamValue("sampleSheetFileName");
  my $assayType = $self->getParamValue("assayType");
  my $datasetName = $self->getParamValue("datasetName");

  my $loadPeakCalls = $self->getBooleanParamValue("loadPeakCalls");

  my $peaksProfileSetName = "NA";
  my $peakFinderArgs = "NA";

  # always call peaks even if we don't load them
  if($assayType eq 'chipChip') {
      $peaksProfileSetName = "${datasetName} [ChIP-chip peaks]";
      $peakFinderArgs = $self->getParamValue("peakFinderArgs");
  }

  my $clusterServer = $self->getSharedConfig('clusterServer');

  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $executor = $self->getClusterExecutor();

  my $clusterConfigFile = "\$baseDir/conf/${executor}.config";

  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$nextflowConfigFile");
  } else {
      my $nextflowConfig = "$workflowDataDir/$nextflowConfigFile";
      open(F, ">$nextflowConfig") || die "Can't open task prop file '$nextflowConfig' for writing";

      my $configString = <<NEXTFLOW;
params {
  assayType = "$assayType"
  input = "$digestedInputDirectory"
  samplesheetFileName = "$sampleSheetFileName"
  outDir = "$digestedOutputDir"
  platformBamFile = "$digestedProbesBam"
  peakFinderArgs = "$peakFinderArgs"
  seqSizeFile = "$digestedSeqSizes"
  profileSetName = "$peaksProfileSetName"
}

process {
    maxForks = $maxForks
}

includeConfig "$clusterConfigFile"

NEXTFLOW

      print F $configString;
      close(F);
  }
}






1;
