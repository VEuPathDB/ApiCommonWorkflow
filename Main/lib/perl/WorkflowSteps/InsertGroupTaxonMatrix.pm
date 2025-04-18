package ApiCommonWorkflow::Main::WorkflowSteps::InsertGroupTaxonMatrix;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $gusConfigFile = $workflowDataDir . "/" . $self->getParamValue('gusConfigFile');

  my $args = " --gusConfigFile $gusConfigFile";

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertOrthomclGroupTaxonMatrix", $args);

}
