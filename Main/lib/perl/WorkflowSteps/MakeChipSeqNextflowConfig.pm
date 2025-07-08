package ApiCommonWorkflow::Main::WorkflowSteps::MakeChipSeqNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use warnings;
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $datasetType = "chipSeq";
  my $removePCRDuplicates = "false";

  my $inputFileType = $self->getParamValue("readsFileType");
  my $experimentType = $self->getParamValue("experimentType");
  my $profileSetName = $self->getParamValue("profileSetName");

  my $resultsDirectory = $self->getParamValue("resultsDirectory");
  my $sampleSheet = $self->getParamValue("sampleSheetFile");
  my $genomeFile = $self->getParamValue("genomeFile");
  my $inputDir = $self->getParamValue("inputDir");

  my $nextflowConfigFile = $self->getParamValue("nextflowConfigFile");

  my $hasPairedEnds = $self->getBooleanParamValue("hasPairedEnds") ? "true" : "false";
  my $extraBowtieParams = $self->getParamValue("extraBowtieParams");

  my $organismAbbrev = $self->getParamValue("organismAbbrev");

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $workingDirRelativePath = $self->getParamValue("workingDirRelativePath");
  my $digestedInputDirPath = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $inputDir);

  my $digestedGenomeFilePath = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $genomeFile);
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
    input                      = "$digestedInputDirPath"
    outputDir                  = "$digestedOutputDir"
    genome                     = "$digestedGenomeFilePath"
    samplesheetFileName        = "$sampleSheet"
    datasetType                = "$datasetType"
    hasPairedReads             = $hasPairedEnds
    removePCRDuplicates        = $removePCRDuplicates
    saveAlignments             = false
    saveCoverage               = true
    inputFileType              = "$inputFileType"
    experimentType             = "$experimentType"
    profileSetName             = "$profileSetName"
    gffFileName                = "chipSeq_peaks.gff"
}

includeConfig "$clusterConfigFile"

process {
  maxForks = 10
}

process {

    withName: bowtie2 {
        ext.args = '$extraBowtieParams'
    }

}


NEXTFLOW

      print F $configString;
      close(F);
  }
}

1;
