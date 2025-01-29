package ApiCommonWorkflow::Main::WorkflowSteps::InsertOrthoGroupAASequence;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $workflowDataDir = $self->getWorkflowDataDir();

    my $groupsFile = $self->getParamValue('groupsFile');

    my $orthoFileFullPath = "$workflowDataDir/$groupsFile";

    my $args = " --orthoFile $orthoFileFullPath";

    $self->testInputFile('inputGroupsDir', "$orthoFileFullPath");
    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertOrthoGroupAASequence", $args);

}
