package ApiCommonWorkflow::Main::WorkflowSteps::InsertPreviousGroupMapping;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $workflowDataDir = $self->getWorkflowDataDir();
	my $gusConfigFile = $workflowDataDir . "/" . $self->getParamValue('gusConfigFile');
    my $mappingFile = $workflowDataDir . "/" . $self->getParamValue('mappingFile');
  
    my $args = " --mappingFile $mappingFile --gusConfigFile $gusConfigFile";

    if($undo) {
        $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertPreviousGroupMapping", $args);
    } else {
        $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertPreviousGroupMapping", $args);
    }

}

1;
