package ApiCommonWorkflow::Main::WorkflowSteps::InsertOrthoGroupBlastValues;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $groupBlastValuesFile = $self->getParamValue('groupBlastValuesFile');
    my $workflowDataDir = $self->getWorkflowDataDir();
    my $gusConfigFile = $workflowDataDir . "/" . $self->getParamValue('gusConfigFile');
  
    my $args = " --groupBlastValuesFile $workflowDataDir/$groupBlastValuesFile --outputBlastValuesDatFile $workflowDataDir/OrthoMCL/peripheral/analysisDir/temp.dat --gusConfigFile $gusConfigFile";

    if($undo) {
        $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertOrthoGroupBlastValues", $args);
    } else {
        $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertOrthoGroupBlastValues", $args);
    }

}

1;
