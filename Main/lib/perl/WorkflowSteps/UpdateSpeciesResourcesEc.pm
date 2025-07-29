package ApiCommonWorkflow::Main::WorkflowSteps::UpdateSpeciesResourcesEc;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
    my ($self, $test, $undo) = @_;

    my $workflowDataDir = $self->getWorkflowDataDir();

    my $dataDir = $self->getParamValue('gusConfigFile');

    my $args = " --gusConfigFile $gusConfigFile";

    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::UpdateSpeciesResourcesEc", $args);

}
