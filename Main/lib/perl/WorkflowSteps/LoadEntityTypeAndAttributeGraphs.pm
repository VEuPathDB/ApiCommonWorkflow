package ApiCommonWorkflow::Main::WorkflowSteps::LoadEntityTypeAndAttributeGraphs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my @args = ();
    my $logDir = join ("/", $self->getWorkflowDataDir(), $self->getParamValue("logDir"));
    mkdir $logDir unless (-d $logDir || $undo);
    push @args, "--logDir", $logDir;
    push @args, "--extDbRlsSpec", "'" . $self->getParamValue("extDbRlsSpec") . "'";
    push @args, "--ontologyExtDbRlsSpec", "'" . $self->getParamValue("ontologyExtDbRlsSpec") . "'";
    push @args, "--schema", $self->getParamValue("schema");
    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::LoadEntityTypeAndAttributeGraphs", join(" ", @args));
}
1;
