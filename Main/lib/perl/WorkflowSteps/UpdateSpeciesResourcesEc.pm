package ApiCommonWorkflow::Main::WorkflowSteps::UpdateSpeciesResourcesEc;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
    my ($self, $test, $undo) = @_;

    my $workflowDataDir = $self->getWorkflowDataDir();
	my $gusConfigFile = $workflowDataDir . "/" . $self->getParamValue('gusConfigFile');

    my $dataDir = $self->getParamValue('dataDir');
    $dataDir = "$workflowDataDir/$dataDir";

    my $args = " --dataDir $dataDir --gusConfigFile $gusConfigFile";

    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::UpdateSpeciesResourcesEc", $args);

}
