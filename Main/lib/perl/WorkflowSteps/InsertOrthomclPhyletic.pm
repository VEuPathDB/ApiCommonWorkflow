package ApiCommonWorkflow::Main::WorkflowSteps::InsertOrthomclPhyletic;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $groupsFile = $self->getParamValue('groupsFile');
    my $orthoFileFullPath = "$workflowDataDir/$groupsFile";
    my $gusConfigFile = $workflowDataDir . "/" . $self->getParamValue('gusConfigFile');

    my $args = " --groupsFile $orthoFileFullPath --gusConfigFile $gusConfigFile";

    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertPhylogeneticProfile", $args);

}
