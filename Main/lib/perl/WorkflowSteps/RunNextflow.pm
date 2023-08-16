package ApiCommonWorkflow::Main::WorkflowSteps::RunNextflow;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

# Abstract method for generation of nextflow config
sub nextflowConfigAsString { }

# this is often needed by subclasses when generating config file
sub getResultsDirectory {
    my ($self) = @_;
    my $workflowDataDir = $self->getWorkflowDataDir();
    my $resultsDir = $self->getParamValue('resultsDir');

    return "${workflowDataDir}${resultsDir}";
}

sub getWorkingDirectory {
    my ($self) = @_;
    my $workflowDataDir = $self->getWorkflowDataDir();
    my $workingDir = $self->getParamValue('workingDir');

    return "${workflowDataDir}${workingDir}";
}


sub run {
    my ($self, $test, $undo) = @_;

    my $workingDirectory = $self->getWorkingDirectory();
    my $nextflowConfigAsString = $self->nextflowConfigAsString();

    chdir $workingDirectory;

    my $nextflowConfig = "$workingDirectory/nextflow.config";
    my $nextflowLog = "$workingDirectory/nextflow.log";
    my $nextflowWork = "$workingDirectory/work";
    open(CONFIG, ">$nextflowConfig") or die "Cannot open $nextflowConfig for writing: $!";
    print CONFIG $nextflowConfigAsString;
    close CONFIG;

    my $nextflowWorkflow = $self->getParamValue('nextflowWorkflow');
    my $isGitRepo = $self->getBooleanParamValue("isGitRepo");
    my $gitBranch = $self->getParamValue("gitBranch");
    my $nextflowEntry = $self->getParamValue("nextflowEntry");

    my $entry;
    if($nextflowEntry) {
        $entry = "-entry $nextflowEntry";
    }

    my $cmd = "export NXF_WORK=$nextflowWork && nextflow -log $nextflowLog -C $nextflowConfig run -ansi-log false -r $gitBranch $nextflowWorkflow $entry -with-trace -resume 1>&2";
    if($isGitRepo){
        $cmd = "nextflow pull $nextflowWorkflow; $cmd";
    }

    # prepend slash to ;, >, and & so that the command is submitted whole
    #$cmd =~ s{([;>&])}{\\$1}g;

    if($undo) {
        # this will undo all of the plugins in reverse order from the last run
        $self->runCmd(0, "undoNextflowPlugins.bash");

        # after the plugins have been Undone.. we can remove the working dir
        $self->runCmd(0, "rm -rf $nextflowWork");
        $self->runCmd(0, "rm -f $nextflowConfig");
        $self->runCmd(0, "rm -f ${nextflowLog}*");
        $self->runCmd(0, "rm -f $workingDirectory/trace*");
        $self->runCmd(0, "rm -rf $workingDirectory/results") if (-d "$workingDirectory/results");
        $self->runCmd(0, "rm $workingDirectory/.nextflow* -rf");
    }
    else {

        my $msgForError=
"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Since this nextflow step FAILED, please CLEAN UP by calling:

  pushd $workingDirectory; undoNextflowPlugins.bash && rm -rf .nextflow/; popd

(You need to do this cleanup EVEN IF the step did not write any data to *its*
tables.  ga most likely wrote to WorkflowStepAlgInvocation, and those rows
must be cleaned out.)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
";

        $self->runCmd($test, $cmd, $msgForError);
    }
}

1;
