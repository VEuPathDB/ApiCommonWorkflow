package ApiCommonWorkflow::Main::WorkflowSteps::MakeOrthoFinderPostUpdateEntryNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $analysisDir = $self->getParamValue("analysisDir");
  my $coreBestRepsFasta = $self->getParamValue("coreBestRepsFasta");
  my $existingResidualBestRepsFasta = $self->getParamValue("existingResidualBestRepsFasta");
  my $newResidualBestRepsFasta = $self->getParamValue("newResidualBestRepsFasta");
  my $existingResidualFasta = $self->getParamValue("existingResidualFasta");
  my $newResidualFasta = $self->getParamValue("newResidualFasta");
  my $coreAndPeripheralProteome = $self->getParamValue("coreAndPeripheralProteome");
  my $updatedGroupsFile = $self->getParamValue("updatedGroupsFile");
  my $updatedResidualGroupsFile = $self->getParamValue("updatedResidualGroupsFile");
  my $oldGroupsFile = $self->getParamValue("oldGroupsFile");
  my $updatedGroupFastas = $self->getParamValue("updatedGroupFastas");
  my $existingResidualGroupFastas = $self->getParamValue("existingResidualGroupFastas");
  my $newResidualGroupFastas = $self->getParamValue("newResidualGroupFastas");
  my $bestRepDiamondOutputFields = $self->getParamValue("bestRepDiamondOutputFields");
  my $buildVersion = $self->getSharedConfig("buildVersion");

  my $resultsDirectory = $self->getParamValue("clusterResultDir");
  my $configPath = join("/", $self->getWorkflowDataDir(), $self->getParamValue("analysisDir"), $self->getParamValue("configFileName"));

  my $workingDirRelativePath = $self->getParamValue("workingDirRelativePath");

  my $coreBestRepsFastaInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $coreBestRepsFasta);
  my $existingResidualBestRepsFastaInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $existingResidualBestRepsFasta);
  my $newResidualBestRepsFastaInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $newResidualBestRepsFasta);
  my $existingResidualFastaInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $existingResidualFasta);
  my $newResidualFastaInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $newResidualFasta);
  my $coreAndPeripheralProteomeInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $coreAndPeripheralProteome);
  my $updatedGroupsFileInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $updatedGroupsFile);
  my $updatedResidualGroupsFileInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $updatedResidualGroupsFile);
  my $oldGroupsFileInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $oldGroupsFile);
  my $updatedGroupFastasInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $updatedGroupFastas);
  my $existingResidualGroupFastasInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $existingResidualGroupFastas);
  my $newResidualGroupFastasInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $newResidualGroupFastas);
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
    coreBestRepsFasta = \"$coreBestRepsFastaInNextflowWorkingDirOnCluster\"
    existingResidualBestRepsFasta = \"$existingResidualBestRepsFastaInNextflowWorkingDirOnCluster\"
    newResidualBestRepsFasta = \"$newResidualBestRepsFastaInNextflowWorkingDirOnCluster\"
    existingResidualFasta = \"$existingResidualFastaInNextflowWorkingDirOnCluster\"
    newResidualFasta = \"$newResidualFastaInNextflowWorkingDirOnCluster\"
    coreAndPeripheralProteome = \"$coreAndPeripheralProteomeInNextflowWorkingDirOnCluster\"
    updatedGroupsFile = \"$updatedGroupsFileInNextflowWorkingDirOnCluster\"
    updatedResidualGroupsFile = \"$updatedResidualGroupsFileInNextflowWorkingDirOnCluster\"
    oldGroupsFile = \"$oldGroupsFileInNextflowWorkingDirOnCluster\"
    updatedGroupFastas = \"$updatedGroupFastasInNextflowWorkingDirOnCluster\"
    existingResidualGroupFastas = \"$existingResidualGroupFastasInNextflowWorkingDirOnCluster\"
    newResidualGroupFastas = \"$newResidualGroupFastasInNextflowWorkingDirOnCluster\"
    buildVersion = $buildVersion
    bestRepDiamondOutputFields = \"$bestRepDiamondOutputFields\"
}

process {
  executor = \'$executor\'
  queue = \'$queue\'
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
