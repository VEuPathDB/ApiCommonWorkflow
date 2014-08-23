package ApiCommonWorkflow::Main::WorkflowSteps::RemoveMappedReads;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run{
    my ($self, $test, $undo) = @_;

    # get parameter values
    my $workflowDataDir = $self->getWorkflowDataDir();
    my $bamFile = $self->getParamValue("bamFile");
    my $outFile = $self->getParamValue("outFile");


    my $cmd = "removeMappedReads.pl --bamFileName $workflowDataDir/$bamFile --outFileName $workflowDataDir/$outFile";

    if ($undo){
        $self->runCmd(0, "rm $workflowDataDir/$outFile");
    }else{
        if ($test){
            $self->runCmd(0, "echo test > $workflowDataDir/$outFile");
        }
        $self->runCmd($test, $cmd);
    }
}

1;
