package ApiCommonWorkflow::Main::WorkflowSteps::CreateBamIndex;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run{
    my ($self, $test, $undo) = @_;

    #get parameter values
    my $workflowDataDir = $self->getWorkflowDataDir();
    my $bamFile = $self->getParamValue("bamFile");

    my $cmd = "samtools index $workflowDataDir/$bamFile";

    if ($undo){
        $self->runCmd(0, "rm $workflowDataDir/$bamFile.bai");
    }else{
        if ($test){
            $self->runCmd(0, "echo test > $workflowDataDir/$bamFile.bai");
        }
        $self->runCmd($test, $cmd);
    }
}

1;
