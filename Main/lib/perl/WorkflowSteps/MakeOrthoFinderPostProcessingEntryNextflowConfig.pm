package ApiCommonWorkflow::Main::WorkflowSteps::MakeOrthoFinderPostProcessingEntryNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $analysisDir = $self->getParamValue("analysisDir");
  my $residualFasta = $self->getParamValue("residualFasta");
  my $residualBestRepsFasta = $self->getParamValue("residualBestRepsFasta");
  my $coreBestRepsFasta = $self->getParamValue("coreBestRepsFasta");
  my $coreAndPeripheralGroups = $self->getParamValue("coreAndPeripheralGroups");
  my $coreAndPeripheralProteome = $self->getParamValue("coreAndPeripheralProteome");
  my $residualGroups = $self->getParamValue("residualGroups");
  my $coreGroupFastas = $self->getParamValue("coreGroupFastas");
  my $residualGroupFastas = $self->getParamValue("residualGroupFastas");
  my $buildVersion = $self->getSharedConfig("buildVersion");
  my $oldGroupsFile = $self->getParamValue("oldGroupsFile");
  my $bestRepDiamondOutputFields = $self->getParamValue("bestRepDiamondOutputFields");  

  my $resultsDirectory = $self->getParamValue("clusterResultDir");
  my $configPath = join("/", $self->getWorkflowDataDir(),  $self->getParamValue("analysisDir"), $self->getParamValue("configFileName"));

  my $workingDirRelativePath = $self->getParamValue("workingDirRelativePath");

  my $residualFastaInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $residualFasta);
  my $residualBestRepsFastaInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $residualBestRepsFasta);
  my $coreBestRepsFastaInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $coreBestRepsFasta);
  my $coreAndPeripheralGroupsInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $coreAndPeripheralGroups);
  my $coreAndPeripheralProteomeInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $coreAndPeripheralProteome);
  my $residualGroupsInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $residualGroups);
  my $coreGroupFastasInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $coreGroupFastas);
  my $residualGroupFastasInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $residualGroupFastas);
  my $oldGroupsFileInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $oldGroupsFile);

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
    residualFasta  = \"$residualFastaInNextflowWorkingDirOnCluster\"
    residualBestRepsFasta = \"$residualBestRepsFastaInNextflowWorkingDirOnCluster\"
    coreBestRepsFasta = \"$coreBestRepsFastaInNextflowWorkingDirOnCluster\"
    coreAndPeripheralGroups = \"$coreAndPeripheralGroupsInNextflowWorkingDirOnCluster\"
    coreAndPeripheralProteome = \"$coreAndPeripheralProteomeInNextflowWorkingDirOnCluster\"
    residualGroups = \"$residualGroupsInNextflowWorkingDirOnCluster\"
    coreGroupFastas = \"$coreGroupFastasInNextflowWorkingDirOnCluster\"
    residualGroupFastas = \"$residualGroupFastasInNextflowWorkingDirOnCluster\"
    buildVersion = $buildVersion
    oldGroupsFile = \"$oldGroupsFileInNextflowWorkingDirOnCluster\"
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
