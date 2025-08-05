package ApiCommonWorkflow::Main::WorkflowSteps::InsertCoreGroups;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $workflowDataDir = $self->getWorkflowDataDir();

    my $orthoVersion = $self->getSharedConfig('buildVersion');

    my $groupsFile = $self->getParamValue('groupsFile');

    my $orthoFileFullPath = "$workflowDataDir/$groupsFile";

    my $gusConfigFile = $workflowDataDir . "/" . $self->getParamValue('gusConfigFile');

    my $args = " --orthoFile $orthoFileFullPath --orthoVersion $orthoVersion --extDbName OrthoMCL --extDbVersion dontcare --gusConfigFile $gusConfigFile";

    $self->testInputFile('inputGroupsDir', "$orthoFileFullPath");
    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertCoreOrthoGroups", $args);

}
