package ApiCommonWorkflow::Main::WorkflowSteps::RunNextflowLocal;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

# this is often needed when getting the config file path
sub getResultsDirectory {
    my ($self) = @_;
    my $workflowDataDir = $self->getWorkflowDataDir();
    my $resultsDir = $self->getParamValue('resultsDir');

    return "${workflowDataDir}/${resultsDir}";
}

sub getWorkingDirectory {
    my ($self) = @_;
    my $workflowDataDir = $self->getWorkflowDataDir();
    my $workingDir = $self->getParamValue('workingDir');

    return "${workflowDataDir}/${workingDir}";
}

sub run {
    my ($self, $test, $undo) = @_;

    my $workingDirectory = $self->getWorkingDirectory();
    my $resultsDirectory = $self->getResultsDirectory();
    #my $nextflowConfig = $self->getParamValue('nextflowConfigFile');
    my $nextflowConfig = $self->getWorkflowDataDir() . "/" . $self->getParamValue('nextflowConfigFile');

    chdir $workingDirectory;

    my $nextflowLog = "$workingDirectory/nextflow.log";
    my $nextflowWork = "$workingDirectory/work";

    my $nextflowWorkflow = $self->getParamValue('nextflowWorkflow');
    my $isGitRepo = $self->getBooleanParamValue("isGitRepo");

    my $nextflowWorkflowBranchKey = $self->getParamValue("nextflowWorkflow") . ".branch";
    my $workflowBranch = $self->getSharedConfigRelaxed($nextflowWorkflowBranchKey) ? $self->getSharedConfigRelaxed($nextflowWorkflowBranchKey) : "main";

    my $nextflowEntry = $self->getParamValue("entry");

    my $entry;
    if($nextflowEntry) {
        $entry = "-entry $nextflowEntry";
    }

    my $cmd = "export NXF_SINGULARITY_HOME_MOUNT=true && export NXF_WORK=$nextflowWork && nextflow -log $nextflowLog -C $nextflowConfig run -ansi-log false -r $workflowBranch $nextflowWorkflow $entry -resume 1>&2";
    # if($isGitRepo){
    #     $cmd = "nextflow pull $nextflowWorkflow; $cmd";
    # }

    if($undo) {
        # Remove the working directory and temporary files
        $self->runCmd(0, "rm -rf $nextflowWork");
        $self->runCmd(0, "rm -f ${nextflowLog}*");
        $self->runCmd(0, "rm -f $workingDirectory/trace*");
        $self->runCmd(0, "rm -rf $resultsDirectory") if (-d $resultsDirectory);
        $self->runCmd(0, "rm $workingDirectory/.nextflow* -rf");
    }
    else {
        $self->runCmd($test, $cmd);
    }
}

1;
