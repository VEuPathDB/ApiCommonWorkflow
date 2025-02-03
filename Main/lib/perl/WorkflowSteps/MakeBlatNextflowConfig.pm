package ApiCommonWorkflow::Main::WorkflowSteps::MakeBlatNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $dots = 10;

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $resultsDirectory = $self->getParamValue("resultsDirectory");
    my $configFileName = $self->getParamValue("configFileName");
    my $configPath = join("/", $workflowDataDir,  $self->getParamValue("analysisDir"), $self->getParamValue("configFileName"));
    my $seqFile = $self->getParamValue("queryFile");
    my $fastaSubsetSize = $self->getParamValue("fastaSubsetSize");
    my $databasePath = $self->getParamValue("databasePath");
    my $maxIntronSize = $self->getParamValue("maxIntronSize");
    my $dbType = $self->getParamValue("dbType");
    my $queryType = $self->getParamValue("queryType");
    my $outputFileName = $self->getParamValue("outputFileName");
    my $workingDirRelativePath = $self->getParamValue("workingDirRelativePath");

    my $increasedMemory = $self->getParamValue("increasedMemory");
    my $initialMemory = $self->getParamValue("initialMemory");
    my $maxForks = $self->getParamValue("maxForks");
    my $maxRetries = $self->getParamValue("maxRetries");

    my $executor = $self->getClusterExecutor();
    my $queue = $self->getClusterQueue();

    my $clusterConfigFile = "\$baseDir/conf/${executor}.config";


    if ($undo) {
	$self->runCmd(0,"rm -rf $configPath");
    } else {
	open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";

      my $queryFileInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $seqFile);
      my $databaseInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $databasePath);
      my $resultsDirectoryInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $resultsDirectory);
      my $configString = <<NEXTFLOW;
params {
  queryFasta = "$queryFileInNextflowWorkingDirOnCluster"
  fastaSubsetSize = $fastaSubsetSize
  genomeFasta = "$databaseInNextflowWorkingDirOnCluster"
  dbType = "$dbType"
  queryType = "$queryType"
  outputDir = "$resultsDirectoryInNextflowWorkingDirOnCluster"
  outputFileName = "$outputFileName"
}

process {
    maxForks = $maxForks

    withName: runBlat {
        ext.args = "-dots=$dots -maxIntron=$maxIntronSize"
  }
}

includeConfig "$clusterConfigFile"
NEXTFLOW

    print F $configString;
    close(F);
    }
}
1;
