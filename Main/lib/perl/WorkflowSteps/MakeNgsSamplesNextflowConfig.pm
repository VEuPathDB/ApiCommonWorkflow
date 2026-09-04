package ApiCommonWorkflow::Main::WorkflowSteps::MakeNgsSamplesNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  #NOTE: the subset size here would run "X" number of genomic sequences at a time on the cluster (chromosomes or contigs)
  my $fastaSubsetSize = 5;

  my $finalDir = $self->getParamValue("finalDirectory");
  my $resultsDirectory = $self->getParamValue("resultsDirectory");
  my $analysisDirectory = $self->getParamValue("analysisDirectory");

  my $nextflowConfigFile = $self->getParamValue("nextflowConfigFile");
  my $sampleSheetName = $self->getParamValue("sampleSheetName");
  my $assayType = $self->getParamValue("assayType");
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $fromSRA = $self->getBooleanParamValue("fromSRA") ? "true" : "false";

  # Max SRA file size prefetch will download. If a data load fails because prefetch
  # skipped a run for being "larger than maximum allowed", bump this in the generated
  # config on the cluster and re-run (default sra-tools limit is 20G).
  my $maxDownloadSize = "50G";

  my $gusConfig = $self->getWorkflowDataDir() . "/" . $self->getParamValue('gusConfigFile');
  my $genomeSize = $self->getGenomeSize($test, $organismAbbrev, $gusConfig);
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $workingDirRelativePath = $self->getParamValue("workingDirRelativePath");
  my $digestedFinalDirPath = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $finalDir);
  my $digestedAnalysisDirPath = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $analysisDirectory);
  my $digestedOutputDir = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $resultsDirectory);

  my $clusterServer = $self->getSharedConfig('clusterServer');
  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $executor = $self->getClusterExecutor();
  my $lsfEnv = $self->getNextflowLsfScratchEnvBlock();
  my $queue = $self->getClusterQueue();

  my $clusterConfigFile = "\$baseDir/conf/${executor}.config";

  # Determine maxForks
  my $maxForks = 2;
  if ($assayType eq 'DNASeq') {
    my $sampleSheetPath = "$workflowDataDir/$finalDir/$sampleSheetName";
    my $sampleCount = 0;
    if (open(my $fh, '<', $sampleSheetPath)) {
      while (<$fh>) {
	next if /^\s*#/;   # skip comment lines
	next if /^\s*$/;   # skip blank lines
	next if /^sample/i; # skip header line
	$sampleCount++;
      }
      close($fh);
    } else {
      warn "Could not open sample sheet '$sampleSheetPath': $!. Defaulting maxForks to 2.";
    }

    if    ($sampleCount <= 5)  { $maxForks = 2; }
    elsif ($sampleCount <= 10) { $maxForks = 4; }
    elsif ($sampleCount <= 20) { $maxForks = 6; }
    elsif ($sampleCount <= 50) { $maxForks = 10; }
    else                       { $maxForks = 20; }
  }

  if ($undo) {
      $self->runCmd(0, "rm $workflowDataDir/$nextflowConfigFile");
  } else {
      my $nextflowConfig = "$workflowDataDir/$nextflowConfigFile";
      open(F, ">$nextflowConfig") || die "Can't open task prop file '$nextflowConfig' for writing";

      my $configString = <<NEXTFLOW;
params {
  input = "$digestedFinalDirPath"
  samplesheetName = "$sampleSheetName"
  fromSra = $fromSRA
  outDir = "$digestedOutputDir"
  genomeSize = $genomeSize
  assayType = "$assayType"
  maxDownloadSize = "$maxDownloadSize"
}

process {
  queue = '$queue'
  maxForks = $maxForks
}

includeConfig "$clusterConfigFile"

apptainer.registry   = 'quay.io'
docker.registry      = 'quay.io'
podman.registry      = 'quay.io'
singularity.registry = 'quay.io'

workDir = "$digestedAnalysisDirPath/ngs-samples-work"

NEXTFLOW

      print F $configString . $lsfEnv;
      close(F);
  }
}

1;
