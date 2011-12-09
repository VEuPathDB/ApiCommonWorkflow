package ApiCommonWorkflow::Main::WorkflowSteps::MakeGfClientTaskInputDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    # get parameter values
    my $taskInputDir = $self->getParamValue("taskInputDir");
    my $maxIntronSize = $self->getParamValue("maxIntronSize");
    my $queryFile = $self->getParamValue("queryFile");
    my $targetDir = $self->getParamValue("targetDir");

    my $clusterServer = $self->getSharedConfig('clusterServer');
    my $taskSize = $self->getConfig("taskSize");
    my $gaBinPath = $self->getConfig("$clusterServer.gaBinPath");

    my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
    my $workflowDataDir = $self->getWorkflowDataDir();

    if ($undo) {
	$self->runCmd(0,"rm -rf $workflowDataDir/$taskInputDir");
    }else {

	if ($test) {
	    $self->testInputFile('queryFile', "$workflowDataDir/$queryFile");
	    $self->testInputFile('targetDir', "$workflowDataDir/$targetDir");
	}

	$self->runCmd(0,"mkdir -p $workflowDataDir/$taskInputDir");

	# make controller.prop file
	$self->makeDistribJobControllerPropFile($taskInputDir, 1, $taskSize,
						"DJob::DistribJobTasks::GenomeAlignWithGfClientTask");
	# make task.prop file
	my $taskPropFile = "$workflowDataDir/$taskInputDir/task.prop";
	open(F, ">$taskPropFile") || die "Can't open task prop file '$taskPropFile' for writing";

	print F
	    "gaBinPath=$gaBinPath
targetDirPath=$clusterWorkflowDataDir/$targetDir/nib
queryPath=$clusterWorkflowDataDir/$queryFile
maxIntron=$maxIntronSize
";
	close(F);
    }
}

sub getConfigDeclaration {
    return (
	# [name, default, description]
	['taskSize', "", ""],
	['gaBinPath', "", ""],
	);
}

