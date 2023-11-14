package ApiCommonWorkflow::Main::WorkflowSteps::InsertScaffoldGapFeatures;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');
  my $soExtDbName = $self->getSharedConfig("sequenceOntologyExtDbName");

  my $args = "--extDbRlsSpec '${genomeExtDbRlsSpec}'";

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertScaffoldGapFeatures", $args);

}

1;
