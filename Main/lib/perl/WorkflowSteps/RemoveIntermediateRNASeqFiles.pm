package ApiCommonWorkflow::Main::WorkflowSteps::RemoveIntermediateRNASeqFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run{
    my ($self, $test, $undo) = @_;

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $experimentDir = $self->getParamValue("experimentDir");
    
    unless ($undo){
        $self->runCmd(0, "rm -rf ${workflowDataDir}/${experimentDir}/mergedBigwigs");
        $self->runCmd(0, "rm -rf ${workflowDataDir}/${experimentDir}/normalize_coverage");
        $self->runCmd(0, "rm -rf ${workflowDataDir}/${experimentDir}/results");
        $self->runCmd(0, "rm -rf ${workflowDataDir}/${experimentDir}/TPM");
    }
}

1;
