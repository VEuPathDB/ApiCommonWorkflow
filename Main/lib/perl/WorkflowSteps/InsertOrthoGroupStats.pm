package ApiCommonWorkflow::Main::WorkflowSteps::InsertOrthoGroupStats;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $groupStatsFile = $self->getParamValue('groupStatsFile');
    my $proteinSubset = $self->getParamValue('proteinSubset');
    my $workflowDataDir = $self->getWorkflowDataDir();
  
    my $args = " --groupStatsFile=$workflowDataDir/$groupStatsFile --proteinSubset=$proteinSubset";

    if($undo) {
        $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertOrthoGroupStats", $args);
    } else {
        $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertOrthoGroupStats", $args);
    }

}

1;
