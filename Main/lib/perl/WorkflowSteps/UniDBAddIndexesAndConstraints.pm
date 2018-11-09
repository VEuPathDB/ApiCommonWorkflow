package ApiCommonWorkflow::Main::WorkflowSteps::UniDBAddIndexesAndConstraints;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--rebuildIndexsAndEnableConstraintsOnly --logDir $workflowDataDir --table_reader 'ApiCommonData::Load::UniDBTableReader'";

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertUniDB", $args);

}

1;
