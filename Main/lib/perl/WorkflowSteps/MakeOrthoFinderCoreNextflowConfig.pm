package ApiCommonWorkflow::Main::WorkflowSteps::MakeOrthoFinderCoreNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $proteomes = $self->getParamValue("proteomes");
  my $analysisDir = $self->getParamValue("analysisDir");
  my $blastArgs  = $self->getParamValue("blastArgs");
  my $buildVersion = $self->getSharedConfig("buildVersion");
  my $orthoFinderDiamondOutput  = $self->getParamValue("orthoFinderDiamondOutput");
  my $bestRepDiamondOutput  = $self->getParamValue("bestRepDiamondOutput");
  my $coreCacheDir = $self->getParamValue("coreCacheDir");
  my $outdated = $self->getParamValue("outdated");
  my $resultsDirectory = $self->getParamValue("clusterResultDir");

  my $workingDirRelativePath = $self->getParamValue("workingDirRelativePath");

  my $proteomesInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $proteomes);
  my $coreCacheDirInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $coreCacheDir);
  my $outdatedFileInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $outdated);
  my $resultsDirectoryInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $resultsDirectory);

  my $configPath = join("/", $self->getWorkflowDataDir(),  $self->getParamValue("analysisDir"), $self->getParamValue("configFileName"));

  my $executor = $self->getClusterExecutor();
  my $queue = $self->getClusterQueue();

  if ($undo) {
    $self->runCmd(0,"rm -rf $configPath");
  } else {
    open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";

    print F
"
params {
  proteomes = \"$proteomesInNextflowWorkingDirOnCluster\"
  outputDir = \"$resultsDirectoryInNextflowWorkingDirOnCluster\"
  outdatedOrganisms = \"$outdatedFileInNextflowWorkingDirOnCluster\"
  diamondSimilarityCache  = \"$coreCacheDirInNextflowWorkingDirOnCluster\"
  blastArgs  = \"$blastArgs\"
  buildVersion  = $buildVersion
  orthoFinderDiamondOutputFields  = \"$orthoFinderDiamondOutput\"
  bestRepDiamondOutputFields  = \"$bestRepDiamondOutput\"
}

process {
  executor = \'$executor\'
  queue = \'$queue\'
  withName: \'diamond\' {
    errorStrategy = { task.exitStatus in 130..140 ? \'retry\' : \'finish\' }
    clusterOptions = {
      (task.attempt > 1 && task.exitStatus in 130..140)
        ? \'-M 20000 -R \"rusage [mem=20000] span[hosts=1]\"\'
        : \'-M 25000 -R \"rusage [mem=25000] span[hosts=1]\"\'
    }
  }
  withName: \'computeGroups\' {
    errorStrategy = { task.exitStatus in 130..140 ? \'retry\' : \'finish\' }
    clusterOptions = {
    (task.attempt > 1 && task.exitStatus in 130..140)
      ? \'-M 45000 -R \"rusage [mem=45000] span[hosts=1]\"\'
      : \'-M 40000 -R \"rusage [mem=40000] span[hosts=1]\"\'
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

