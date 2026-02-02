package ApiCommonWorkflow::Main::WorkflowSteps::MakeOrthoFinderPeripheralEntryNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $analysisDir = $self->getParamValue("analysisDir");
  my $peripheralProteomes = $self->getParamValue("peripheralProteomes");
  my $coreProteomes = $self->getParamValue("coreProteome");
  my $coreGroupsFile = $self->getParamValue("coreGroupsFile");
  my $coreGroupSimilarities = $self->getParamValue("coreGroupSimilarities");
  my $coreTranslateSequenceFile = $self->getParamValue("coreTranslateSequenceFile");
  my $outdatedOrganisms = $self->getParamValue("outdatedOrganisms");  
  my $peripheralDiamondCache = $self->getParamValue("peripheralDiamondCache");
  
  my $buildVersion = $self->getSharedConfig("buildVersion");

  my $resultsDirectory = $self->getParamValue("clusterResultDir");
  my $configPath = join("/", $self->getWorkflowDataDir(),  $self->getParamValue("analysisDir"), $self->getParamValue("configFileName"));

  my $workingDirRelativePath = $self->getParamValue("workingDirRelativePath");

  my $peripheralProteomesInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $peripheralProteomes);
  my $coreProteomesInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $coreProteomes);
  my $coreGroupsFileInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $coreGroupsFile);
  my $coreGroupSimilaritiesInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $coreGroupSimilarities);
  my $coreTranslateSequenceFileInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $coreTranslateSequenceFile);
  my $peripheralDiamondCacheInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $peripheralDiamondCache);
  my $outdatedOrganismsFileInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $outdatedOrganisms);
  my $resultsDirectoryInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $resultsDirectory);

  my $executor = $self->getClusterExecutor();
  my $queue = $self->getClusterQueue();

  if ($undo) {
    $self->runCmd(0,"rm -rf $configPath");
  } else {
    open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";

    print F
"
params {
    outputDir = \"$resultsDirectoryInNextflowWorkingDirOnCluster\"
    coreProteomes = \"$coreProteomesInNextflowWorkingDirOnCluster\"
    peripheralProteomes = \"$peripheralProteomesInNextflowWorkingDirOnCluster\"
    coreGroupsFile = \"$coreGroupsFileInNextflowWorkingDirOnCluster\"
    coreGroupSimilarities = \"$coreGroupSimilaritiesInNextflowWorkingDirOnCluster\"
    coreTranslateSequenceFile = \"$coreTranslateSequenceFileInNextflowWorkingDirOnCluster\"
    outdatedOrganisms = \"$outdatedOrganismsFileInNextflowWorkingDirOnCluster\"
    peripheralDiamondCache = \"$peripheralDiamondCacheInNextflowWorkingDirOnCluster\"
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

