package ApiCommonWorkflow::Main::WorkflowSteps::MakeAntismashNextflowConfig;

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
    my $clusterServer = $self->getSharedConfig("clusterServer");
    my $antismashDatabase = join("/", $self->getSharedConfig("$clusterServer.softwareDatabasesDirectory"),$self->getSharedConfig("antismashDatabaseDirectory"));

    my $organism = $self->getParamValue("organism");

    my $fasta = $self->getParamValue("fasta");
    my $gff = $self->getParamValue("gff");
    my $resultDir = $self->getParamValue("resultDir");
    my $workingDirRelativePath = $self->getParamValue("workingDirRelativePath");

    my $digestedFasta = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $fasta);
    my $digestedGff = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $gff);
    my $digestedResultDir = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $resultDir);

    my $executor = $self->getClusterExecutor();
    my $queue = $self->getClusterQueue();

    if ($undo) {
	$self->runCmd(0,"rm -rf $configPath");
    } else {
	open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";

    print F
"
params {
  fasta = \"$digestedFasta\"
  gff = \"$digestedGff\"
  organism = \"$organism\"
  resultDir = \"$digestedResultDir\"
}
process{
  executor = \'$executor\'
  queue = \'$queue\'
}
singularity {
  enabled = true
  autoMounts = true
  runOptions = \"--bind $antismashDatabase:/databases\"
}
";
	close(F);
    }
}

1;
