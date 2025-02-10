package ApiCommonWorkflow::Main::WorkflowSteps::InsertSimilarOrthologGroups;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $similarGroups = $self->getParamValue('similarGroups');
    my $workflowDataDir = $self->getWorkflowDataDir();
  
    my $args = " --similarGroups=$workflowDataDir/$similarGroups";

    if($undo) {
        $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertSimilarOrthologGroups", $args);
    } else {
        $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertSimilarOrthologGroups", $args);
    }

}

1;
