package ApiCommonWorkflow::Main::WorkflowSteps::InsertScaffoldGapFeatures;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');
  my $soExtDbRlsSpec = $self->getParamValue('SOExtDbRlsSpec');
  my $soExtDbName = $self->getSharedConfig("sequenceOntologyExtDbName");

  my $args = "--extDbRlsSpec '${genomeExtDbRlsSpec}' --SOExtDbRlsSpec '$soExtDbRlsSpec'";

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertScaffoldGapFeatures", $args);

}

1;
