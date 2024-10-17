package ApiCommonWorkflow::Main::WorkflowSteps::InsertGenomeBedGraph;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $bedFile = $self->getParamValue('bedFile');
    my $algorithm = $self->getParamValue('algorithm');
    my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');
    my $workflowDataDir = $self->getWorkflowDataDir();

    my $args = "--bedFile=$workflowDataDir/$bedFile --algorithm='$algorithm' --extDbRlsSpec='$extDbRlsSpec'";
  
    if($undo) {
        $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertGenomeBedGraph", $args);
    } else {
        $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertGenomeBedGraph", $args);
    }

}

1;
