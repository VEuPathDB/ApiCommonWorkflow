package ApiCommonWorkflow::Main::WorkflowSteps::MakeBlastPPdbNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # can change these in config if needed
  my $fastaSubsetSize = 2000;
  my $maxForks = 5;
  my $evalue = 0.00001;
  my $mask = "seg";
  my $maxTargetSeqs = 20;

  my $proteinSequenceFile = $self->getParamValue("proteinSequenceFile");
  my $pdbFastaFile = $self->getParamValue("pdbFastaFile");

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
      my $pdbFastaFileInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $pdbFastaFile);
      my $resultsDirectoryInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $resultsDirectory);

      my $configString = <<NEXTFLOW;
params {
  queryFastaFile = "$proteinSequenceFileInNextflowWorkingDirOnCluster"
  outputDir = "$resultsDirectoryInNextflowWorkingDirOnCluster"
  outputFile = "$outputFileName"
  fastaSubsetSize = $fastaSubsetSize
  blastProgram = "blastp"
  targetFastaFile = "$pdbFastaFileInNextflowWorkingDirOnCluster"
  preConfiguredDatabase = false
  targetDatabaseIndex = "NA"
}

process {
    maxForks = $maxForks

    withName: diamondSimilarity {
        ext.args = "--evalue $evalue --masking $mask --max-target-seqs $maxTargetSeqs --sensitive --comp-based-stats 0 -f 6"
    }
}

includeConfig "$clusterConfigFile"

NEXTFLOW

      print F $configString;
      close(F);
  }
}

1;

