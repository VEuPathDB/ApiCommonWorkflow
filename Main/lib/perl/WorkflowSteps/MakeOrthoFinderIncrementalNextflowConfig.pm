package ApiCommonWorkflow::Main::WorkflowSteps::MakeOrthoFinderIncrementalNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $changedOrNewProteomes = $self->getParamValue("changedOrNewProteomes");
  my $fullGroupFile = $self->getParamValue("fullGroupFile");
  my $residualGroupFile = $self->getParamValue("residualGroupFile");
  my $proteinToOrganism = $self->getParamValue("proteinToOrganism");
  my $outdatedOrganisms = $self->getParamValue("outdatedOrganisms");
  my $stableGroupsDatabase = $self->getParamValue("stableGroupsDatabase");
  my $previousFullProteome = $self->getParamValue("previousFullProteome");
  my $cachedCoreBestReps = $self->getParamValue("cachedCoreBestReps");
  my $cachedResidualBestReps = $self->getParamValue("cachedResidualBestReps");
  my $cachedCoreStats = $self->getParamValue("cachedCoreStats");
  my $cachedPeripheralStats = $self->getParamValue("cachedPeripheralStats");
  my $cachedIntraGroupBlastFile = $self->getParamValue("cachedIntraGroupBlastFile");
  my $coreSpeciesIds = $self->getParamValue("coreSpeciesIds");

  my $buildVersion = $self->getSharedConfig("buildVersion");

  my $resultsDirectory = $self->getParamValue("clusterResultDir");
  my $configPath = join("/", $self->getWorkflowDataDir(),  $self->getParamValue("analysisDir"), $self->getParamValue("configFileName"));

  my $workingDirRelativePath = $self->getParamValue("workingDirRelativePath");

  my $changedOrNewProteomesInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $changedOrNewProteomes);
  my $fullGroupFileInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $fullGroupFile);
  my $residualGroupFileInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $residualGroupFile);
  my $proteinToOrganismInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $proteinToOrganism);
  my $outdatedOrganismsInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $outdatedOrganisms);
  my $stableGroupsDatabaseInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $stableGroupsDatabase);
  my $previousFullProteomeInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $previousFullProteome);
  my $cachedCoreBestRepsInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $cachedCoreBestReps);
  my $cachedResidualBestRepsInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $cachedResidualBestReps);
  my $cachedCoreStatsInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $cachedCoreStats);
  my $cachedPeripheralStatsInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $cachedPeripheralStats);
  my $cachedIntraGroupBlastFileInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $cachedIntraGroupBlastFile);
  my $coreSpeciesIdsInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $coreSpeciesIds);
  my $resultsDirectoryInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $resultsDirectory);

  my $executor = $self->getClusterExecutor();
  my $lsfScratch = ($executor eq 'lsf') ? "\n  NXF_SCRATCH = '\$LSF_TMPDIR'" : '';
  my $queue = $self->getClusterQueue();

  if ($undo) {
    $self->runCmd(0,"rm -rf $configPath");
  } else {
    open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";

    print F
"
params {
    outputDir = \"$resultsDirectoryInNextflowWorkingDirOnCluster\"
    changedOrNewProteomes = \"$changedOrNewProteomesInNextflowWorkingDirOnCluster\"
    fullGroupFile = \"$fullGroupFileInNextflowWorkingDirOnCluster\"
    residualGroupFile = \"$residualGroupFileInNextflowWorkingDirOnCluster\"
    proteinToOrganism = \"$proteinToOrganismInNextflowWorkingDirOnCluster\"
    outdatedOrganisms = \"$outdatedOrganismsInNextflowWorkingDirOnCluster\"
    stableGroupsDatabase = \"$stableGroupsDatabaseInNextflowWorkingDirOnCluster\"
    previousFullProteome = \"$previousFullProteomeInNextflowWorkingDirOnCluster\"
    cachedCoreBestReps = \"$cachedCoreBestRepsInNextflowWorkingDirOnCluster\"
    cachedResidualBestReps = \"$cachedResidualBestRepsInNextflowWorkingDirOnCluster\"
    cachedCoreStats = \"$cachedCoreStatsInNextflowWorkingDirOnCluster\"
    cachedPeripheralStats = \"$cachedPeripheralStatsInNextflowWorkingDirOnCluster\"
    cachedIntraGroupBlastFile = \"$cachedIntraGroupBlastFileInNextflowWorkingDirOnCluster\"
    coreSpeciesIds = \"$coreSpeciesIdsInNextflowWorkingDirOnCluster\"
    buildVersion = $buildVersion
    orthoFinderDiamondOutputFields = \"qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore\"
}

process {
  executor = \'$executor\'
  queue = \'$queue\'
  withName: \'incrementalDiamond\' {
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
