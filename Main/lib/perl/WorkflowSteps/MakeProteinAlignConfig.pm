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

  my $workingDirRelativePath = $self->getParamValue("workingDirRelativePath");
  my $digestedQueryFilePath = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $queryFile);
  my $digestedTargetFilePath = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $targetFile);
  my $digestedOutputDir = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $outputDir);

  my $executor = $self->getClusterExecutor();
  my $exonerateProcessMemoryRequirement = processMemoryRequirement($self->getParamValue("exonerateMemory"));
  my $queue = $self->getClusterQueue();

  my $configFile = "$workflowDataDir/$configFileName";

  if ($undo) {
    $self->runCmd(0,"rm -rf $workflowDataDir/$outputDir");
    $self->runCmd(0,"rm -rf $configFile");
  }else {
    #$self->testInputFile('queryFile', "$workflowDataDir/$queryFile");
    #$self->testInputFile('targetDir', "$workflowDataDir/$targetFile");

    $self->runCmd(0,"mkdir -p $workflowDataDir/$outputDir");

    # make task.prop file
    my $configFile = "$workflowDataDir/$configFileName";

    open(F, ">$configFile") || die "Can't open config file '$configFile' for writing";
    my $sharedClusterConfig = $self->getSharedClusterNextflowConfigIncludeBlock($configFile);

    print F
"$sharedClusterConfig
params {
  queryFilePath = '$digestedQueryFilePath'
  targetFilePath = '$digestedTargetFilePath'
  outputDir = '$digestedOutputDir'
  queryChunkSize = $queryChunkSize
  esd2esiMemoryLimit = $esd2esiMemoryLimit
  fsmmemory = $exonerateFsmmemory
  maxintron = $maxIntronSize
  outputFileName = 'nrProteinToGenome.gff'
}

process {
  executor = '$executor'
  queue = '$queue'
  clusterOptions = '-Q \"EXCLUDE(255)\"'
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

sub processMemoryRequirement {
  my ($memoryParameter) = @_;

  my $mbs;
  if ($memoryParameter =~ m{(^\d+(?:\.\d+)?) GB}){
    $mbs = int($1 * 1000);
  } elsif ($memoryParameter =~ m{(\d+) MB}){
    $mbs = int($1);
  } else {
    die "Could not extract num MB/GB from memory parameter: $memoryParameter";
  }
  my $doubleMbs = $mbs * 2;
  my $fiveTimesMbs = $mbs * 5;
  return <<"EOF";
    errorStrategy = { task.exitStatus in 130..140 ? 'retry' : 'terminate' }
    maxRetries = 2
    memory = {
      task.attempt == 1 ? '${mbs} MB'
      : task.attempt == 2 ? '${doubleMbs} MB'
      : '${fiveTimesMbs} MB'
    }
EOF
}

1;

