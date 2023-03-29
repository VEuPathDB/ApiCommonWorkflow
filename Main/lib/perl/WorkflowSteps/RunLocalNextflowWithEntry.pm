package ApiCommonWorkflow::Main::WorkflowSteps::RunNextflowWithEntry;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $analysisDir = $self->getParamValue("analysisDir");
    my $resultsDir = $self->getParamValue("resultsDir");
    my $nextflowConfigFile = $self->getParamValue("nextflowConfigFile");
    my $nextflowWorkflow = $self->getParamValue("nextflowWorkflow");
    my $entry = $self->getParamValue("entry");
    my $isGitRepo = $self->getBooleanParamValue("isGitRepo");
    my $gitBranch = $self->getParamValue("gitBranch");
    my $nextflowWorkDir = "$analysisDir/work";

    $nextflowWorkflow = "https://github.com/".$nextflowWorkflow;

    my $workflowDataDir = $self->getWorkflowDataDir();

    my $workflowDir = "$workflowDataDir/$analysisDir";
    my $workflowResultsDir = "$workflowDir/$resultsDir";
    my $workflowNextflowConfigFile = "$workflowDir/$nextflowConfigFile";
    my $workflowWorkingDir = "$workflowDir/work";

    my $jobInfoFile = "$workflowDir/clusterJobInfo.txt";
    my $logFile = "$workflowDir/.nextflow.log";
    my $traceFile = "$workflowDir/trace.txt";
    my $nextflowStdoutFile = "$workflowDir/nextflow.txt";

    chdir $workflowDir; 

    my $cmd = "export NXF_WORK=$workflowWorkingDir && nextflow -C $workflowNextflowConfigFile run -r $gitBranch -entry $entry $nextflowWorkflow -resume 1>&2";
    if($isGitRepo){
        $cmd = "nextflow pull $nextflowWorkflow; $cmd";
    }

    if($undo) {
        # this will undo all of the plugins in reverse order from the last run
        $self->runCmd(0, "undoNextflowPlugins.bash");

        # after the plugins have been Undone.. we can remove the working dir
        $self->runCmd(0, "rm -rf $workflowDir/work");
        $self->runCmd(0, "rm -f $workflowNextflowConfigFile");
        $self->runCmd(0, "rm -f ${logFile}*");
        $self->runCmd(0, "rm -f ${traceFile}*");
        $self->runCmd(0, "rm $workflowDir/.nextflow* -rf");
        # Current solution for webservicesDir
        $self->runCmd(0, "rm -rf $workflowDir/*");
    }
    else {
        if(-d  ".nextflow/") {
            # run the undoNextflowPlugins.bash
            system("undoNextflowPlugins.bash -f failed")
	} 
        $self->runCmd($test, $cmd);
    }
}

1;
