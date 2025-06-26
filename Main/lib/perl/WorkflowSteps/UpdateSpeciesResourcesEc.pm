package ApiCommonWorkflow::Main::WorkflowSteps::UpdateSpeciesResourcesEc;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
    my ($self, $test, $undo) = @_;

    my $workflowDataDir = $self->getWorkflowDataDir();

    my $dataDir = $self->getParamValue('dataDir');
    $dataDir = "$workflowDataDir/$dataDir";

    my $args = " --dataDir $dataDir";

    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::UpdateSpeciesResourcesEc", $args);

}
