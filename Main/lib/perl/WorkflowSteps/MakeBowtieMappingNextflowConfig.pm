package ApiCommonWorkflow::Main::WorkflowSteps::MakeBowtieMappingNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $clusterResultDir = join("/", $clusterWorkflowDataDir, $self->getParamValue("clusterResultDir"));
  my $analysisDir = $self->getParamValue("analysisDir");
  my $configFileName = $self->getParamValue("configFileName");
  my $configPath = join("/", $self->getWorkflowDataDir(),  $self->getParamValue("analysisDir"), $configFileName);

  my $input = join("/", $clusterWorkflowDataDir, $self->getParamValue("input"));
  my $mateA = join("/", $clusterWorkflowDataDir, $self->getParamValue("readsFile"));
  my $mateB = join("/", $clusterWorkflowDataDir, $self->getParamValue("pairedReadsFile"));
  my $databaseFileDir = join("/", $clusterWorkflowDataDir, $self->getParamValue("indexDir"));
  my $databaseFasta = join("/", $clusterWorkflowDataDir, $self->getParamValue("databaseFasta"));

  my $sampleName= $self->getParamValue("sampleName");
  my $extraBowtieParams = $self->getParamValue("extraBowtieParams");
  my $downloadMethod = $self->getConfig("downloadMethod");
  
  my $preconfiguredDatabase = $self->getParamValue("preconfiguredDatabase");
  my $removePCRDuplicates = $self->getParamValue("removePCRDuplicates");
  my $writeBedFile = $self->getParamValue("writeBedFile");
  my $hasPairedReads = $self->getConfig("hasPairedReads");  

  my $executor = $self->getClusterExecutor();
  my $queue = $self->getClusterQueue();

  if ($undo) {
    $self->runCmd(0,"rm -rf $configPath");
  } else {
    open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";

    print F
"
params {
  preconfiguredDatabase = $preconfiguredDatabase
  writeBedFile = $writeBedFile
  hasPairedReads = $hasPairedReads
  removePCRDuplicates = $removePCRDuplicates
  input = \"$input\"
  downloadMethod = \'$downloadMethod\'
  databaseFasta = \"$databaseFasta\"
  databaseFileDir = \"$databaseFileDir\"
  indexFileBasename = \"genomicIndexes\"
  outputDir = \"$clusterResultDir\"
  sampleName = \"$sampleName\"
  mateA = \"$mateA\"
  mateB = \"$mateB\"
  extraBowtieParams = \"$extraBowtieParams\"
}
process {
  container = 'veupathdb/bowtiemapping'
  executor = \'$executor\'
  queue = \'$queue\'
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

