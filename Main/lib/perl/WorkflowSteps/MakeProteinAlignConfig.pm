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
  my $exonerateProcessMemoryRequirement = processMemoryRequirement($executor, $self->getParamValue("exonerateMemory"));
  my $queue = $self->getClusterQueue();

  my $configFile = "$workflowDataDir/$configFileName";

  if ($undo) {
    $self->runCmd(0,"rm -rf $workflowDataDir/$outputDir");
    $self->runCmd(0,"rm -rf $configFile");
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
  container = \"veupathdb/proteintogenomealignment\"
  executor = '$executor'
  queue = '$queue'
  withName: 'exonerate' {
    maxForks = $exonerateMaxForks
    $exonerateProcessMemoryRequirement
  }
}

singularity {
  enabled = true
  autoMounts = true
}

";

  close(F);
 }
}

sub clusterOptionsForMemMbs {
  my ($mbs) = @_;
  return "-M ${mbs} -R \"rusage [mem=${mbs}] span[hosts=1]\"";
}

sub processMemoryRequirement {
  my ($executor, $memoryParameter) = @_;

  # If not on LSF:
  # Assume the Nextflow shorthands for memory use are correct
  # Also, don't attempt the three tries
  return "memory = '$memoryParameter'" unless $executor eq 'lsf';

  # On PMACS LSF, the parameters don't correctly translate to memory requirements
  # Prepare a submission string instead
  my $mbs;
  if ($memoryParameter =~ m{(^\d+(?:\.\d+)?) GB}){
    $mbs = int($1 * 1000);
  } elsif ($memoryParameter =~ m{(\d+) MB}){
    $mbs = int($1);
  } else {
    die "Could not extract num MB/GB from memory parameter: $memoryParameter";
  }
  my $s1 = clusterOptionsForMemMbs(0.5 * $mbs);
  my $s2 = clusterOptionsForMemMbs($mbs);
  my $s3 = clusterOptionsForMemMbs(2 * $mbs);
  return <<"EOF";
    errorStrategy = { task.exitStatus in 130..140 ? 'retry' : 'terminate' }
    maxRetries = 3
    clusterOptions = {
      task.attempt == 1 ? '$s1'
      : task.attempt == 2 ?'$s2'
      : '$s3'
    }
EOF
}

1;

