package ApiCommonWorkflow::Main::WorkflowSteps::LoadDatasetSpecificEntityGraph;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my @args = ();
    push @args, "--extDbRlsSpec", "'" . $self->getParamValue("extDbRlsSpec") . "'";
    push @args, "--schema", $self->getParamValue("schema");
    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::LoadDatasetSpecificEntityGraph", join(" ", @args));
}
1;
