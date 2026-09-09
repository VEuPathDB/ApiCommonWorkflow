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

  # residualBuildVersion is normally a static, one-time-set shared config
  # value (correct for the full-rebuild path, where postResidualEntry only
  # ever runs once). The incremental path reuses postResidualEntry every
  # run and needs a fresh, incremented value each time to avoid renumbering
  # brand-new residual groups into an already-used r${N} namespace -- it
  # passes residualBuildVersionFile (computed by ComputeNextResidualBuildVersion)
  # to override the static value with this run's actual next one.
  my $residualBuildVersionFile = $self->getParamValue("residualBuildVersionFile");
  my $residualBuildVersion;
  if ($residualBuildVersionFile) {
    my $fullPath = join("/", $self->getWorkflowDataDir(), $residualBuildVersionFile);
    open(my $fh, '<', $fullPath) || die "Could not open file $fullPath: $!";
    $residualBuildVersion = <$fh>;
    close($fh);
    chomp $residualBuildVersion;
    $residualBuildVersion =~ s/\s+//g;
  } else {
    $residualBuildVersion = $self->getSharedConfig("residualBuildVersion");
  }

  # Same override pattern for the brand-new-residual-group numbering offset: 0 for the
  # full-rebuild path (nothing yet exists to collide with), or the highest OGR number any
  # earlier run has already used, computed by the incremental path via
  # findHighestResidualGroupNumber against the cached baseline.
  my $residualGroupNumberOffsetFile = $self->getParamValue("residualGroupNumberOffsetFile");
  my $residualGroupNumberOffset;
  if ($residualGroupNumberOffsetFile) {
    my $fullPath = join("/", $self->getWorkflowDataDir(), $residualGroupNumberOffsetFile);
    open(my $fh, '<', $fullPath) || die "Could not open file $fullPath: $!";
    $residualGroupNumberOffset = <$fh>;
    close($fh);
    chomp $residualGroupNumberOffset;
    $residualGroupNumberOffset =~ s/\s+//g;
  } else {
    $residualGroupNumberOffset = 0;
  }

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
  my $lsfScratch = ($executor eq 'lsf') ? "\n  NXF_SCRATCH = '\${LSF_TMPDIR:-}'" : '';
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
    residualGroupNumberOffset = $residualGroupNumberOffset
}

process {
  beforeScript = 'module load apptainer/1.4.1 && unset LD_LIBRARY_PATH'
  executor = \'$executor\'
  queue = \'$queue\'
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
