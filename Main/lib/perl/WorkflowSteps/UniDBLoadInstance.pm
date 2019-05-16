package ApiCommonWorkflow::Main::WorkflowSteps::UniDBLoadInstance;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $databaseInstance = $self->getParamValue('databaseInstance');
  my $readerClass = $self->getParamValue('readerClass');
  my $loaderLogDir = $self->getParamValue('loaderLogDir');
  my $forceSkipDatasetFile = $self->getParamValue('forceSkipDatasetFile');
  my $forceLoadDatasetFile = $self->getParamValue('forceLoadDatasetFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--database $databaseInstance --table_reader '$readerClass' --logDir $workflowDataDir/$loaderLogDir --mode load";

	$args .= " --forceSkipDatasetFile $forceSkipDatasetFile" if(-e $forceSkipDatasetFile);
	$args .= " --forceLoadDatasetFile $forceLoadDatasetFile" if(-e $forceLoadDatasetFile);

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertUniDB", $args);

}

1;
