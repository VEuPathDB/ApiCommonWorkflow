package ApiCommonWorkflow::Main::WorkflowSteps::MakeTRNAScanConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

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

  # Leave the soft-masked (lowercase) repeat bases as they are rather than
  # converting them to N.  Not every organism has a masked genome to begin with.
  # TODO:  this could be made a step param if we need to change it per genome
  my $applyHardMask = "false";

  # EukHighConfidenceFilter score cutoffs (tRNAscan-SE tool defaults), emitted
  # explicitly so the generated config records what filtered the annotation.
  my $cmScore = 50;     # -c1 domain/overall model score
  my $ssScore = 10;     # -m1 secondary structure score
  my $isoScore = 70;    # -e1 isotype-specific model score

  # Infernal score cutoff, used only when applyHighConfFilter is false
  my $minInfScore = 60;

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $clusterServer = $self->getSharedConfig('clusterServer');
  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $executor = $self->getClusterExecutor();

  my $clusterConfigFile = "\$baseDir/conf/${executor}.config";

  # Only lsf takes a queue; the includeConfig above is already executor specific.
  # Emitted after the include so the workflow's queue wins over any default there.
  my $queueBlock = $executor eq 'lsf'
    ? "process {\n  queue = '" . $self->getClusterQueue() . "'\n}\n"
    : "";

  if ($undo) {
      $self->runCmd(0, "rm $workflowDataDir/$nextflowConfigFile");
  } else {

    my $genomicSequenceFileOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $genomicSequenceFile);
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

$queueBlock
NEXTFLOW

    close F;
  }
}

1;
