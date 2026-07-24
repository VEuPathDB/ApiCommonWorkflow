package ApiCommonWorkflow::Main::WorkflowSteps::MakeTRNAScanConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use File::Basename;

sub run {
  my ($self, $test, $undo) = @_;

  my $fastaSubsetSize = 10;

  my $genomicSequenceFile = $self->getParamValue("genomicSequenceFile");
  my $nextflowConfigFile = $self->getParamValue("nextflowConfigFile");
  my $resultsDirectory = $self->getParamValue("resultsDirectory");
  my $trnascanOutputFileName = $self->getParamValue("outputFileName");
  my $trnascanGFFFileName = $self->getParamValue("outputGFFName");

  my $workingDirRelativePath = $self->getParamValue("workingDirRelativePath");

  # Retain only tRNAscan-SE's high confidence set (EukHighConfidenceFilter).
  my $applyHighConfFilter = "true";

  # The input is RepeatMasker's soft-masked genome, so have the pipeline convert
  # the lowercase (repeat) bases to N before scanning.
  my $applyHardMask = "true";

  # EukHighConfidenceFilter score cutoffs (tRNAscan-SE tool defaults), emitted
  # explicitly so the generated config records what filtered the annotation.
  my $cmScore = 50;     # -c1 domain/overall model score
  my $ssScore = 10;     # -m1 secondary structure score
  my $isoScore = 70;    # -e1 isotype-specific model score

  # Infernal score cutoff, used only when applyHighConfFilter is false
  my $minInfScore = 60;

  # ----------------------------------------------------------------------------
  # TODO TEMPORARY - remove at the next full rebuild.
  #
  # tRNAscan must run on the RepeatMasked genome, but the trnascan graph lives in
  # postLoadGenome, which has no dependency on maskGenome.  The real fix is to
  # move the trnascan subgraph out of postLoadGenome to a point that depends on
  # the repeat masked genome.  We can't do that now: changing the graph would
  # invalidate many downstream genome steps in workflows that have already run.
  #
  # Until then we ignore the genomicSequenceFile param, symlink the RepeatMasked
  # genome next to it, and hand the symlink to nextflow.
  #
  # Consequence of the missing dependency: nothing guarantees the masked genome
  # exists when this step runs.  If it doesn't, we fail below and the step must be
  # rerun once maskGenome has produced blocked.seq.
  # ----------------------------------------------------------------------------
  my $maskedGenomeFile = $genomicSequenceFile;
  $maskedGenomeFile =~ s|/postLoadGenome/.*|/maskGenome/analysisDir/results/blocked.seq|
    or $self->error("Cannot derive the RepeatMasked genome path from genomicSequenceFile '$genomicSequenceFile': expected a path under postLoadGenome");

  my $maskedGenomeSymLink = dirname($genomicSequenceFile) . "/genome_masked.fasta";

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $clusterServer = $self->getSharedConfig('clusterServer');
  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $executor = $self->getClusterExecutor();

  my $clusterConfigFile = "\$baseDir/conf/${executor}.config";

  if ($undo) {
      $self->runCmd(0, "rm $workflowDataDir/$nextflowConfigFile");
      $self->runCmd(0, "rm -f $workflowDataDir/$maskedGenomeSymLink");
  } else {

    # see the TEMPORARY note above
    $self->error("The RepeatMasked genome '$workflowDataDir/$maskedGenomeFile' does not exist yet.  Rerun this step after maskGenome has made blocked.seq for this organism.")
      unless -e "$workflowDataDir/$maskedGenomeFile";

    $self->runCmd(0, "ln -sf $workflowDataDir/$maskedGenomeFile $workflowDataDir/$maskedGenomeSymLink");

    my $genomicSequenceFileOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $maskedGenomeSymLink);
    my $resultsDirectoryOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $resultsDirectory);

    my $nextflowConfig = "$workflowDataDir/$nextflowConfigFile";
    open(F, ">$nextflowConfig") || die "Cannot open '$nextflowConfig' for writing\n";

    print F <<NEXTFLOW;
params {
  inputFilePath = "$genomicSequenceFileOnCluster"
  outputDir = "$resultsDirectoryOnCluster"
  outputFileName = "$trnascanOutputFileName"
  outputGFFName = "$trnascanGFFFileName"
  fastaSubsetSize = $fastaSubsetSize

  applyHardMask = $applyHardMask
  applyHighConfFilter = $applyHighConfFilter

  cmScore = $cmScore
  ssScore = $ssScore
  isoScore = $isoScore

  minInfScore = $minInfScore
}

includeConfig "$clusterConfigFile"

NEXTFLOW

    close F;
  }
}

1;
