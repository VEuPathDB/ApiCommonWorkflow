package ApiCommonWorkflow::Main::WorkflowSteps::MakeProteinAlignConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameter values
  my $queryFile = $self->getParamValue("queryFile");
  my $targetFile = $self->getParamValue("targetFile");
  my $outputDir = $self->getParamValue("outputDir");
  my $maxIntronSize = $self->getParamValue("maxIntronSize");
  my $configFileName = $self->getParamValue("configFileName");

  my $queryChunkSize = $self->getParamValue("queryChunkSize");
  my $esd2esiMemoryLimit = $self->getParamValue("esd2esiMemoryLimit");
  my $exonerateFsmmemory = $self->getParamValue("exonerateFsmmemory");
  my $exonerateMaxForks = $self->getParamValue("exonerateMaxForks");

  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $executor = $self->getClusterExecutor();
  my $queue = $self->getClusterQueue();

  if ($undo) {
    $self->runCmd(0,"rm -rf $workflowDataDir/$outputDir");
  }else {
    $self->testInputFile('queryFile', "$workflowDataDir/$queryFile");
    $self->testInputFile('targetDir', "$workflowDataDir/$targetFile");

    $self->runCmd(0,"mkdir -p $workflowDataDir/$outputDir");

    # make task.prop file
    my $configFile = "$workflowDataDir/$configFileName";

    open(F, ">$configFile") || die "Can't open config file '$configFile' for writing";

    print F
"params {
  queryFilePath = '$clusterWorkflowDataDir/$queryFile'
  targetFilePath = '$clusterWorkflowDataDir/$targetFile'
  outputDir = '$clusterWorkflowDataDir/$outputDir'
  queryChunkSize = $queryChunkSize
  esd2esiMemoryLimit = $esd2esiMemoryLimit
  fsmmemory = $exonerateFsmmemory
  maxintron = $maxIntronSize
}

process {
  executor = '$executor'
  queue = '$queue'
  withName: 'exonerate' { maxForks = $exonerateMaxForks }
}

";

  close(F);
 }
}

1;

