package ApiCommonWorkflow::Main::WorkflowSteps::AnalyzeWebreadyPartitionedTables;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

# create a child partition table

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $gusConfigFile = $self->getParamValue('gusConfigFile');

  $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";

  my $schema = $self->getSharedConfig('webreadySchema');

  my $args = "--schema $schema";
  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::CreateDenormalizedTable", $args);

}

1;

