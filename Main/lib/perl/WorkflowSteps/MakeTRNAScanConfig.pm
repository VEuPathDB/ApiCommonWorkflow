package ApiCommonWorkflow::Main::WorkflowSteps::MakeTRNAScanConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $fastaSubsetSize = 10;

  my $genomicSequenceFile = $self->getParamValue("genomicSequenceFile");
  my $nextflowConfigFile = $self->getParamValue("nextflowConfigFile");
  my $resultsDirectory = $self->getParamValue("resultsDirectory");
  my $trnascanOutputFileName = $self->getParamValue("outputFileName");
  my $trnascanGFFFileName = $self->getParamValue("outputGFFName");

  my $workingDirRelativePath = $self->getParamValue("workingDirRelativePath");
  my $organismAbbrev = $self->getParamValue("organismAbbrev");
  my $gusConfigFile = $self->getWorkflowDataDir() . "/" . $self->getParamValue("gusConfigFile");
  #print STDERR "\$gusConfigFile = $gusConfigFile\n";

  # use genus here for repeatMaskSpecies 
  my $repeatMaskSpecies = $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getFullName();
  $repeatMaskSpecies =~ s/(\S+?)\s.*/$1/; 
  #print STDERR "\$repeatMaskSpecies = $repeatMaskSpecies\n";

  # Minimum tRNAscan-SE Inf score to retain a prediction (both filter paths)
  # 60 bits is conservative and reliable across eukaryotes
  # Lower to 50 only if a curated reference shows genuine tRNAs below 60
  # Default 60 bits; lower only if a well-annotated
  my $minInfScore = 60;

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $clusterServer = $self->getSharedConfig('clusterServer');
  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $executor = $self->getClusterExecutor();

  my $clusterConfigFile = "\$baseDir/conf/${executor}.config";

  if ($undo) {
      $self->runCmd(0, "rm $workflowDataDir/$nextflowConfigFile");
  } else {

    my $genomicSequenceFileOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $genomicSequenceFile);
    my $resultsDirectoryOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $resultsDirectory);

    my $applyHighConfFilter = "true";
    my $applyRepeatMask     = "true";

    my $nextflowConfig = "$workflowDataDir/$nextflowConfigFile";
    open(F, ">$nextflowConfig") || die "Cannot open '$nextflowConfig' for writing\n";

    print F <<NEXTFLOW;
params {
  inputFilePath = "$genomicSequenceFileOnCluster"
  outputDir = "$resultsDirectoryOnCluster"
  outputFileName = "$trnascanOutputFileName"
  outputGFFName = "$trnascanGFFFileName"
  fastaSubsetSize = $fastaSubsetSize

  applyHighConfFilter = $applyHighConfFilter
  applyRepeatMask = $applyRepeatMask

  repeatMaskSpecies = "$repeatMaskSpecies"

  minInfScore = $minInfScore
}

includeConfig "$clusterConfigFile"

NEXTFLOW

    close F;
  }
}

1;
