package ApiCommonWorkflow::Main::WorkflowSteps::MakeBlatNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $dots = 10;

    my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
    my $workflowDataDir = $self->getWorkflowDataDir();
    my $outputDir = join("/", $clusterWorkflowDataDir, $self->getParamValue("outputDir")); 
    my $configFileName = $self->getParamValue("configFileName");
    my $configPath = join("/", $workflowDataDir,  $self->getParamValue("analysisDir"), $self->getParamValue("configFileName"));
    my $seqFile = join("/", $clusterWorkflowDataDir, $self->getParamValue("queryFile"));
    my $fastaSubsetSize = $self->getParamValue("fastaSubsetSize");
    my $databasePath = join("/", $clusterWorkflowDataDir, $self->getParamValue("databasePath"));
    my $maxIntronSize = $self->getParamValue("maxIntronSize");
    my $dbType = $self->getParamValue("dbType");
    my $queryType = $self->getParamValue("queryType");
    my $outputFileName = $self->getParamValue("outputFileName");

    my $increasedMemory = $self->getParamValue("increasedMemory");
    my $initialMemory = $self->getParamValue("initialMemory");
    my $maxForks = $self->getParamValue("maxForks");
    my $maxRetries = $self->getParamValue("maxRetries");

    my $executor = $self->getClusterExecutor();
    my $queue = $self->getClusterQueue();

    my $executor = $self->getClusterExecutor();
    my $clusterConfigFile = "\$baseDir/conf/${executor}.config";


    if ($undo) {
	$self->runCmd(0,"rm -rf $configPath");
    } else {
	open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";


      my $configString = <<NEXTFLOW;
params {
  queryFasta = "$seqFile"
  fastaSubsetSize = $fastaSubsetSize
  genomeFasta = "$databasePath"
  dbType = "$dbType"
  queryType = "$queryType"
  outputDir = "$outputDir"
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
