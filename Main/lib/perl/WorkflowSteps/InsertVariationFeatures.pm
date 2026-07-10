package ApiCommonWorkflow::Main::WorkflowSteps::InsertVariationFeatures;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $inputDir       = $self->getParamValue('inputDir');
  my $extDbRlsSpec   = $self->getParamValue('extDbRlsSpec');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--inputDir $workflowDataDir/$inputDir "
           . "--extDbRlsSpec '$extDbRlsSpec' "
           . "--organismAbbrev '$organismAbbrev'";

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertVariationFeatures", $args);
}

1;
