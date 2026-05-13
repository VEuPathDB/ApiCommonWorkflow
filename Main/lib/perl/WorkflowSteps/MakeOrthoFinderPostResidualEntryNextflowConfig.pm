package ApiCommonWorkflow::Main::WorkflowSteps::MakeOrthoFinderPostResidualEntryNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $analysisDir = $self->getParamValue("analysisDir");
  my $residualFasta = $self->getParamValue("residualFasta");
  my $groupsFile = $self->getParamValue("groupsFile");
  my $speciesMapping = $self->getParamValue("speciesMapping");
  my $sequenceMapping = $self->getParamValue("sequenceMapping");
  my $diamondResultsFile = $self->getParamValue("diamondResultsFile");    
  my $buildVersion = $self->getSharedConfig("buildVersion");
  my $residualBuildVersion = $self->getSharedConfig("residualBuildVersion");

  my $resultsDirectory = $self->getParamValue("clusterResultDir");
  my $configPath = join("/", $self->getWorkflowDataDir(),  $self->getParamValue("analysisDir"), $self->getParamValue("configFileName"));

  my $workingDirRelativePath = $self->getParamValue("workingDirRelativePath");

  my $residualFastaInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $residualFasta);
  my $groupsFileInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $groupsFile);
  my $speciesMappingInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $speciesMapping);
  my $sequenceMappingInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $sequenceMapping);  
  my $diamondResultsFileInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $diamondResultsFile);
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
    residualFasta = \"$residualFastaInNextflowWorkingDirOnCluster\"
    groupsFile = \"$groupsFileInNextflowWorkingDirOnCluster\"
    speciesMapping = \"$speciesMappingInNextflowWorkingDirOnCluster\"
    sequenceMapping = \"$sequenceMappingInNextflowWorkingDirOnCluster\"
    diamondResultsFile = \"$diamondResultsFileInNextflowWorkingDirOnCluster\"
    buildVersion = $buildVersion
    residualBuildVersion = $residualBuildVersion
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
