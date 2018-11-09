package ApiCommonWorkflow::Main::WorkflowSteps::UniDBLoadInstance;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $databaseInstance = $self->getParamValue('databaseInstance');
  my $readerClass = $self->getParamValue('readerClass');
  my $loaderLogDir = $self->getParamValue('loaderLogDir');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--database $databaseInstance --table_reader '$readerClass' --logDir $workflowDataDir/$loaderLogDir --mode load";

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertUniDB", $args);

}

1;
