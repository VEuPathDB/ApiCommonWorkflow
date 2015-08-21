package ApiCommonWorkflow::Main::WorkflowSteps::MakeChipSeqPeakCalls;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run{
    my ($self, $test, $undo) = @_;
    
    my $experimentDataDir = $self->getParamValue('experimentDataDir');
    my $experimentType = $self->getParamValue('experimentType');
    my $workflowDataDir = $self->getWorkflowDataDir();
    my $experimentDataDir = "$workflowDataDir/$experimentDataDir/";  
    
    my $cmd = "makeChipSeqPeakCalls.pl --experimentType $experimentType --experimentDataDir $experimentDataDir";	

    if ($undo){
        $self->runCmd(0, "rm -rf $experimentDataDir/peaks/");
    }
    else{
        $self->runCmd($test, $cmd);
    }
}

1;
