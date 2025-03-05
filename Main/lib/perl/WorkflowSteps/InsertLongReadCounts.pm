package ApiCommonWorkflow::Main::WorkflowSteps::InsertLongReadCounts;


@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $gffFile = $self->getParamValue('gffFile');
    my $countFile = $self->getParamValue('countFile');
    my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');
    my $analysisConfig = $self->getParamValue('analysisConfig');

    my $workflowDataDir = $self->getWorkflowDataDir();

    my $args = <<"EOF";
--gffFile=$workflowDataDir/$gffFile \\
--countFile=$workflowDataDir/$countFile \\
--extDbSpec=$extDbRlsSpec \\
--analysisConfig=$workflowDataDir/$analysisConfig \\
EOF

    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertLongReadCounts" , $args);

}

1;
