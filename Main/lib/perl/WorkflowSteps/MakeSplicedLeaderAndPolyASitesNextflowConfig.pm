package ApiCommonWorkflow::Main::WorkflowSteps::MakeSplicedLeaderAndPolyASitesNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use warnings;
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $datasetType = "spliceSites"; 
  my $removePCRDuplicates = "false";

  my $inputFileType = $self->getParamValue("inputFileType");

  my $resultsDirectory = $self->getParamValue("resultsDirectory");
  my $sampleSheet = $self->getParamValue("sampleSheetFile");
  my $genomeFile = $self->getParamValue("genomeFile");
  my $inputDir = $self->getParamValue("inputDir");

  my $nextflowConfigFile = $self->getParamValue("nextflowConfigFile");
  
  my $hasPairedEnds = $self->getBooleanParamValue("hasPairedEnds") ? "true" : "false";

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
    saveAlignments             = true
    saveCoverage               = false
    inputFileType              = "$inputFileType"
}

includeConfig "$clusterConfigFile"

process {
  maxForks = 10
}

process {

    withName: bowtie2 {
        ext.args = ''
    }

}
                                

NEXTFLOW

      print F $configString;
      close(F);
  }
}

1;
