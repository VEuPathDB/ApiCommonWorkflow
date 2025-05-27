package ApiCommonWorkflow::Main::WorkflowSteps::InsertOrthomclPhyletic;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $gusConfigFile = $workflowDataDir . "/" . $self->getParamValue('gusConfigFile');
    my $groupsFile = $self->getParamValue('groupsFile');
    my $orthoFileFullPath = "$workflowDataDir/$groupsFile";

    my $args = " --groupsFile $orthoFileFullPath --gusConfigFile $gusConfigFile";

    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertPhylogeneticProfile", $args);

}
