package ApiCommonWorkflow::Main::WorkflowSteps::MakeOrthoFinderUpdateResidualEntryNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $analysisDir = $self->getParamValue("analysisDir");
  my $newResidualFastaDir = $self->getParamValue("newResidualFastaDir");
  my $existingResidualGroupsFile = $self->getParamValue("existingResidualGroupsFile");

  my $buildVersion = $self->getSharedConfig("buildVersion");
  my $newResidualBuildVersion = $self->getSharedConfig("newResidualBuildVersion");
  my $residualBuildVersion = $self->getSharedConfig("residualBuildVersion");

  my $resultsDirectory = $self->getParamValue("clusterResultDir");
  my $configPath = join("/", $self->getWorkflowDataDir(), $self->getParamValue("analysisDir"), $self->getParamValue("configFileName"));

  my $workingDirRelativePath = $self->getParamValue("workingDirRelativePath");

  my $newResidualFastaDirInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $newResidualFastaDir);
  my $existingResidualGroupsFileInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $existingResidualGroupsFile);
  my $resultsDirectoryInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $resultsDirectory);

  my $executor = $self->getClusterExecutor();
  my $queue = $self->getClusterQueue();

  if ($undo) {
    $self->runCmd(0, "rm -rf $configPath");
  } else {
    die "newResidualBuildVersion ($newResidualBuildVersion) in steps.config matches the existing residualBuildVersion ($residualBuildVersion). " .
        "New residual groups would collide with existing groups (both prefixed OGR${buildVersion}r${newResidualBuildVersion}_). " .
        "Set newResidualBuildVersion to a different value in steps.config."
        if $newResidualBuildVersion == $residualBuildVersion;

    open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";

    print F
"
params {
    outputDir = \"$resultsDirectoryInNextflowWorkingDirOnCluster\"
    newResidualFastaDir = \"$newResidualFastaDirInNextflowWorkingDirOnCluster\"
    existingResidualGroupsFile = \"$existingResidualGroupsFileInNextflowWorkingDirOnCluster\"
    buildVersion = $buildVersion
    newResidualBuildVersion = $newResidualBuildVersion
    orthoFinderDiamondOutputFields = \"qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore\"
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
