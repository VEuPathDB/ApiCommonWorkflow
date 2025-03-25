package ApiCommonWorkflow::Main::WorkflowSteps::MakeIprscan5NextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;
    my $workflowDataDir = $self->getWorkflowDataDir();
    my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
    my $configFileName = $self->getParamValue("configFileName");
    my $configPath = join("/", $workflowDataDir,  $self->getParamValue("analysisDir"), $self->getParamValue("configFileName"));
    my $outputFile = $self->getParamValue("outputFile");
    my $clusterServer = $self->getSharedConfig("clusterServer");
    my $interproscanDatabase = join("/", $self->getSharedConfig("$clusterServer.softwareDatabasesDirectory"),$self->getSharedConfig("interproscanDatabaseDirectory"));

    my $input = $self->getParamValue("input");
    my $outputDir = $self->getParamValue("outputDir");
    my $workingDirRelativePath = $self->getParamValue("workingDirRelativePath");

    my $digestedInput = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $input);
    my $digestedOutputDir = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $outputDir);

    my $executor = $self->getClusterExecutor();
    my $queue = $self->getClusterQueue();

    if ($undo) {
	$self->runCmd(0,"rm -rf $configPath");
    } else {
	open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";

    print F
"
params {
  input = \"$digestedInput\"
  outputDir = \"$digestedOutputDir\"
  fastaSubsetSize = 100
  appls = \"cdd,coils,gene3d,hamap,panther,pfama,pirsf,prints,prositeprofiles,prositepatterns,sfld,smart,superfamily,ncbifam,mobidblite\"
  outputFile = \"$outputFile\"
}

process{
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
