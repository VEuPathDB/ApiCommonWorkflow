package ApiCommonWorkflow::Main::WorkflowSteps::InsertEpitopesAcession;


@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $peptideFile = $self->getParamValue('peptideFile');
    my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');

    my $workflowDataDir = $self->getWorkflowDataDir();

    my $args = <<"EOF";
--peptideFile=$workflowDataDir/$peptideFile \\
--extDbSpec=$extDbRlsSpec \\
EOF

    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertEpitopesAcession" , $args);

}

1;
