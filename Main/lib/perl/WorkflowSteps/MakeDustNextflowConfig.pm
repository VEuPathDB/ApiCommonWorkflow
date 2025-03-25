package ApiCommonWorkflow::Main::WorkflowSteps::MakeDustNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  #NOTE: the subset size here would run "X" number of genomic sequences at a time on the cluster (chromosomes or contigs)
  my $fastaSubsetSize = 5;

  my $genomicSequenceFile = $self->getParamValue("genomicSequenceFile");
  my $nextflowConfigFile = $self->getParamValue("nextflowConfigFile");
  my $resultsDirectory = $self->getParamValue("resultsDirectory");
  my $outputFileName = $self->getParamValue("outputFileName");

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
  fastaSubsetSize = $fastaSubsetSize
  seqType = "na"
}

includeConfig "$clusterConfigFile"

NEXTFLOW

      print F $configString;
      close(F);
  }
}

1;
