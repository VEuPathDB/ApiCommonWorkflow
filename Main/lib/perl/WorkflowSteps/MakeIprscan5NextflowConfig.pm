package ApiCommonWorkflow::Main::WorkflowSteps::MakeIprscan5NextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;
    my $workflowDataDir = $self->getWorkflowDataDir();
    my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
    my $input = join("/", $clusterWorkflowDataDir, $self->getParamValue("input")); 
    my $outputDir = join("/", $clusterWorkflowDataDir, $self->getParamValue("outputDir")); 
    my $configFileName = $self->getParamValue("configFileName");
    my $configPath = join("/", $workflowDataDir,  $self->getParamValue("analysisDir"), $self->getParamValue("configFileName"));
    my $outputFile = $self->getParamValue("outputFile");
    my $clusterServer = $self->getSharedConfig("clusterServer");
    my $interproscanDatabase = join("/", $self->getSharedConfig("$clusterServer.softwareDatabasesDirectory"),$self->getSharedConfig("interproscanDatabaseDirectory"));

    my $executor = $self->getClusterExecutor();
    my $queue = $self->getClusterQueue();

    if ($undo) {
	$self->runCmd(0,"rm -rf $configPath");
    } else {
	open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";

    print F
"
params {
  input = \"$input\"
  outputDir = \"$outputDir\"
  fastaSubsetSize = 100
  appls = \"prositeprofiles,pfama,gene3d,superfamily,pirsf,smart\" 
  outputFile = \"$outputFile\"
}

process{
  container = 'rdemko2332/interproscan:latest'
  executor = \'$executor\'
  queue = \'$queue\'
  maxForks = 40
  maxRetries = 2
  withName: 'Iprscan' {
    errorStrategy = { task.exitStatus in 130..140 ? \'retry\' : \'finish\' }
    clusterOptions = {
      (task.attempt > 1 && task.exitStatus in 130..140)
        ? \'-M 12000 -R \"rusage [mem=12000] span[hosts=1]\"\'
        : \'-M 4000 -R \"rusage [mem=4000] span[hosts=1]\"\'
    }
  }                                                                                                                                                                             \
}

singularity {
  enabled = true
  autoMounts = true
  runOptions = \"--bind $interproscanDatabase:/opt/interproscan/data --bind $interproscanDatabase/interproscan.properties:/opt/interproscan/interproscan.properties\" 
}
";
	close(F);
    }
}

1;
