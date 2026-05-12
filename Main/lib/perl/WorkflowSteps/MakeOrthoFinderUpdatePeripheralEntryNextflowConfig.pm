package ApiCommonWorkflow::Main::WorkflowSteps::MakeOrthoFinderUpdatePeripheralEntryNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $analysisDir = $self->getParamValue("analysisDir");
  my $newPeripheralProteomes = $self->getParamValue("newPeripheralProteomes");
  my $coreProteomes = $self->getParamValue("coreProteomes");
  my $coreGroupsFile = $self->getParamValue("coreGroupsFile");
  my $coreGroupSimilarities = $self->getParamValue("coreGroupSimilarities");
  my $existingGroupsFile = $self->getParamValue("existingGroupsFile");
  my $existingBestReps = $self->getParamValue("existingBestReps");
  my $existingFullProteome = $self->getParamValue("existingFullProteome");
  my $peripheralDiamondCache = $self->getParamValue("peripheralDiamondCache");
  my $coreTranslateSequenceFile = $self->getParamValue("coreTranslateSequenceFile");

  my $buildVersion = $self->getSharedConfig("buildVersion");

  my $resultsDirectory = $self->getParamValue("clusterResultDir");
  my $configPath = join("/", $self->getWorkflowDataDir(), $self->getParamValue("analysisDir"), $self->getParamValue("configFileName"));

  my $workingDirRelativePath = $self->getParamValue("workingDirRelativePath");

  my $newPeripheralProteomesInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $newPeripheralProteomes);
  my $coreProteomesInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $coreProteomes);
  my $coreGroupsFileInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $coreGroupsFile);
  my $coreGroupSimilaritiesInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $coreGroupSimilarities);
  my $existingGroupsFileInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $existingGroupsFile);
  my $existingBestRepsInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $existingBestReps);
  my $existingFullProteomeInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $existingFullProteome);
  my $peripheralDiamondCacheInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $peripheralDiamondCache);
  my $coreTranslateSequenceFileInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $coreTranslateSequenceFile);
  my $resultsDirectoryInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $resultsDirectory);

  my $executor = $self->getClusterExecutor();
  my $queue = $self->getClusterQueue();

  if ($undo) {
    $self->runCmd(0, "rm -rf $configPath");
  } else {
    open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";

    print F
"
params {
    outputDir = \"$resultsDirectoryInNextflowWorkingDirOnCluster\"
    newPeripheralProteomes = \"$newPeripheralProteomesInNextflowWorkingDirOnCluster\"
    coreProteomes = \"$coreProteomesInNextflowWorkingDirOnCluster\"
    coreGroupsFile = \"$coreGroupsFileInNextflowWorkingDirOnCluster\"
    coreGroupSimilarities = \"$coreGroupSimilaritiesInNextflowWorkingDirOnCluster\"
    existingGroupsFile = \"$existingGroupsFileInNextflowWorkingDirOnCluster\"
    existingBestReps = \"$existingBestRepsInNextflowWorkingDirOnCluster\"
    existingFullProteome = \"$existingFullProteomeInNextflowWorkingDirOnCluster\"
    peripheralDiamondCache = \"$peripheralDiamondCacheInNextflowWorkingDirOnCluster\"
    coreTranslateSequenceFile = \"$coreTranslateSequenceFileInNextflowWorkingDirOnCluster\"
    buildVersion = $buildVersion
    orthoFinderDiamondOutputFields = \"qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore\"
}

process {
  executor = \'$executor\'
  queue = \'$queue\'
  withName: \'peripheralDiamond\' {
    errorStrategy = { task.exitStatus in 130..140 ? \'retry\' : \'finish\' }
    clusterOptions = {
      (task.attempt > 1 && task.exitStatus in 130..140)
        ? \'-M 20000 -R \"rusage [mem=20000] span[hosts=1]\"\'
        : \'-M 25000 -R \"rusage [mem=25000] span[hosts=1]\"\'
    }
  }
}

env {
  _JAVA_OPTIONS=\"-Xmx8192M\"
  NXF_OPTS=\"-Xmx8192M\"
  NXF_JVM_ARGS=\"-Xmx8192M\"
}

singularity {
  enabled = true
  autoMounts = true
}
";
    close(F);
  }
}

1;
