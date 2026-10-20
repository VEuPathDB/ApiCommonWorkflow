package ApiCommonWorkflow::Main::WorkflowSteps::AnalyzeWebreadyPartitionedTables;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

# analyze the parent tables of the partitioned webready tables

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $schema = $self->getSharedConfig('webreadySchema');

  my $args = "--schema $schema";
  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::AnalyzePartitionedTables", $args);

}

1;

