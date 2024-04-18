package ApiCommonWorkflow::Main::WorkflowSteps::InsertAaSequenceEpitope;


@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $peptideResultFile = $self->getParamValue('peptideResultFile');
    my $extDbSpec = $self->getParamValue('extDbSpec');

    my $workflowDataDir = $self->getWorkflowDataDir();

    my $args = <<"EOF";
--peptideResultFile=$workflowDataDir/$peptideResultFile \\
--extDbSpec=$workflowDataDir/$extDbSpec \\
EOF

    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertLongReadCounts" , $args);

}

1;
