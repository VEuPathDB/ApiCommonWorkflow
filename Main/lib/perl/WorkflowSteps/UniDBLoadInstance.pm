package ApiCommonWorkflow::Main::WorkflowSteps::UniDBLoadInstance;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $projectName = $self->getParamValue('projectName');

  my $componentProps = $self->getSharedConfig($projectName . "_PROPS");
  my $componentPropsHash = eval $componentProps;
  $self->error("error in PROPS object in stepsShared.prop for $projectName") if($@);
  my $databaseInstance = $componentPropsHash->{instance};
  unless($databaseInstance) {
    $self->error("instance must be specified in PROPS object in stepsShared.prop for $projectName");
  }

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
