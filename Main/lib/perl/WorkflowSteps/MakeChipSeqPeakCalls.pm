package ApiCommonWorkflow::Main::WorkflowSteps::MakeChipSeqPeakCalls;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run{
    my ($self, $test, $undo) = @_;
    
    my $experimentDataDir = $self->getParamValue('experimentDataDir');
    my $experimentType = $self->getParamValue('experimentType');
    my $experimentName = $self->getParamValue('experimentName');
    my $workflowDataDir = $self->getWorkflowDataDir();
    
    my $cmd = "makeChipSeqPeakCalls.pl --workflowDir $workflowDataDir --experimentType $experimentType --experimentName $experimentName --experimentDataDir $experimentDataDir";	

    if ($undo){
        $self->runCmd(0, "rm -rf $workflowDataDir/$experimentDataDir/peaks/");
    }
    else{
        $self->runCmd($test, $cmd);
    }
}

1;
