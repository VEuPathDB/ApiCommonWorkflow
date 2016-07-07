package ApiCommonWorkflow::Main::WorkflowSteps::InsertSplicedLeaderAndPolyASitesGenes;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');
  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');

  my $args = "--genomeExtDbRlsSpec $genomeExtDbRlsSpec --extDbRlsSpec $extDbRlsSpec";

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertSpliceSiteGenes", $args);
}

1;
