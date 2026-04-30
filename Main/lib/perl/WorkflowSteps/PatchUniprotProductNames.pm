package ApiCommonWorkflow::Main::WorkflowSteps::PatchUniprotProductNames;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $organismAbbrev = $self->getParamValue('organismAbbrev');

  my $args = "--psqlFile $ENV{GUS_HOME}/lib/psql/patches/uniprotProductNames.psql --organismAbbrev $organismAbbrev";

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::PatchGenomeAndAnnotation", $args);
}

1;
