package ApiCommonWorkflow::Main::WorkflowSteps::InsertEpitopeNAFeature;


@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $peptideResultFile = $self->getParamValue('peptideResultFile');
    my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');

    my $workflowDataDir = $self->getWorkflowDataDir();

    my $args = <<"EOF";
--peptideResultFile=$workflowDataDir/$peptideResultFile \\
--extDbSpec=$extDbRlsSpec \\
EOF

    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertEpitopeNAFeature" , $args);

}

1;
