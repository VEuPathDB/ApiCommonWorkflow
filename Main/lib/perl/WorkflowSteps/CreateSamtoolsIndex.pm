package ApiCommonWorkflow::Main::WorkflowSteps::CreateSamtoolsIndex;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run{
    my ($self, $test, $undo) = @_;

    #get parameter values
    my $workflowDataDir = $self->getWorkflowDataDir();
    my $genomicSeqsFile = $self->getParamValue("genomicSeqsFile");
    my $outputFile = $self->getParamValue("outputFile");

    my $cmd = "samtools faidx $workflowDataDir/$genomicSeqsFile";
    my $cmd2 = "mv $workflowDataDir/$genomicSeqsFile.fai $workflowDataDir/$outputFile";

    if ($undo){
        $self->runCmd(0, "rm $workflowDataDir/$outputFile");
    }else{
        if ($test){
            $self->runCmd(0, "echo test > $workflowDataDir/$outputFile");
        }
        $self->runCmd($test, $cmd);
        $self->runCmd($test,$cmd2);
    }
}

1;
