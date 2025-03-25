package ApiCommonWorkflow::Main::WorkflowSteps::InsertAaSequenceEpitope;


@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $peptideResultFile = $self->getParamValue('peptideResultFile');

    my $genomeSpec = $self->getParamValue("genomeSpec");

    my $workflowDataDir = $self->getWorkflowDataDir();

    my $args = "--peptideResultFile '$workflowDataDir/$peptideResultFile' --genomeExtDbRlsSpec '$genomeSpec'";

    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertAaSequenceEpitope" , $args);

}

1;
