package ApiCommonWorkflow::Main::WorkflowSteps::MakePsiPredNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
    my $inputFilePath = join("/", $clusterWorkflowDataDir, $self->getParamValue("inputFilePath")); 
    my $outputDir = join("/", $clusterWorkflowDataDir, $self->getParamValue("outputDir")); 
    my $configFileName = $self->getParamValue("configFileName");
    my $configPath = join("/", $workflowDataDir,  $self->getParamValue("analysisDir"), $self->getParamValue("configFileName"));
    my $increasedMemory = $self->getParamValue("increasedMemory");
    my $initialMemory = $self->getParamValue("initialMemory");
    my $maxForks = $self->getParamValue("maxForks");
    my $maxRetries = $self->getParamValue("maxRetries");

    my $executor = $self->getClusterExecutor();
    my $queue = $self->getClusterQueue();
  
    if ($undo) {
	$self->runCmd(0,"rm -rf $configPath");
    } else {
	open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";

    print F
"
params {
  inputFilePath = \"$inputFilePath\"
  outputDir = \"$outputDir\"
}

process{
  container = 'veupathdb/psipred:latest'
  executor = \'$executor\'
  queue = \'$queue\'
  maxForks = $maxForks
  maxRetries = $maxRetries
  withName: 'runPsipred' {
    errorStrategy = { task.exitStatus in 130..140 ? \'retry\' : \'finish\' }
    clusterOptions = {
      (task.attempt > 1 && task.exitStatus in 130..140)
        ? \'-M $increasedMemory -R \"rusage [mem=$increasedMemory] span[hosts=1]\"\'
        : \'-M $initialMemory -R \"rusage [mem=$initialMemory] span[hosts=1]\"\'
    }
  }                                                                                                                                                                             \
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
