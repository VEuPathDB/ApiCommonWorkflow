package ApiCommonWorkflow::Main::WorkflowSteps::InsertVirtualLocations;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $ncbiTaxonId = $self->getParamValue('ncbiTaxonId');
  my $mode = $self->getParamValue('mode');
  my $pluginName = $self->getParamValue('pluginName');

  my $args = "--ncbiTaxonId $ncbiTaxonId --mode $mode";

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::$pluginName", $args);
}

1;
