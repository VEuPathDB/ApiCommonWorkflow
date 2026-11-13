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
  my $lsfScratch = ($executor eq 'lsf') ? "\n  NXF_SCRATCH = '\${LSF_TMPDIR:-}'" : '';
  my $queue = $self->getClusterQueue();

  if ($undo) {
    $self->runCmd(0,"rm -rf $configPath");
  } else {
    open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";
    my $sharedClusterConfig = $self->getSharedClusterNextflowConfigIncludeBlock($configPath);

    print F
"$sharedClusterConfig
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
  beforeScript = 'module load apptainer/1.4.1 && unset LD_LIBRARY_PATH'
  executor = \'$executor\'
  queue = \'$queue\'
  clusterOptions = \'-Q \"EXCLUDE(255)\"\'
  withName: \'diamond\' {
    errorStrategy = { task.exitStatus in 130..140 ? \'retry\' : \'finish\' }
    memory = { task.attempt > 1 ? \'20 GB\' : \'25 GB\' }
  }
  withName: \'computeGroups\' {
    errorStrategy = { task.exitStatus in 130..140 ? \'retry\' : \'finish\' }
    memory = { task.attempt > 1 ? \'45 GB\' : \'40 GB\' }
  }
}
env {
  _JAVA_OPTIONS=\"-Xmx8192M\"
  NXF_OPTS=\"-Xmx8192M\"
  NXF_JVM_ARGS=\"-Xmx8192M\"$lsfScratch
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

