package ApiCommonWorkflow::Main::WorkflowSteps::RunNextflowLocalMergeDNASeq;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::RunNextflowLocal);

use strict;

use ApiCommonWorkflow::Main::WorkflowSteps::RunNextflowLocal;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


# OVERRIDE
# We always want to use main for for mergeExperiments dnaseq nextflow workflow
# Only the processSingleExperiment should use the tag
sub getSharedConfigRelaxed {
    my ($self, $key) = @_;

    if($key eq 'VEuPathDB/dnaseq-nextflow') {
        return undef;
    }

    return $self->SUPER::getSharedConfigRelaxed($key);
}


1;
