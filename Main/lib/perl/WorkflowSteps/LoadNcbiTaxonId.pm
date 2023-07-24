package ApiCommonWorkflow::Main::WorkflowSteps::LoadNcbiTaxonId;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $organismFullName = $self->getParamValue('organismFullName');
  my $ncbiTaxonId = $self->getParamValue('ncbiTaxonId');

  my $args = "--ncbiTaxId $ncbiTaxonId --rank 'no rank' --name '$organismFullName' --nameClass 'scientific name'";

  $self->runPlugin($test, $undo, "GUS::Supported::Plugin::InsertTaxonAndTaxonName", $args);

}


1;
