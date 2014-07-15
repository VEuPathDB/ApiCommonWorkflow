package ApiCommonWorkflow::Main::WorkflowSteps::InsertDbRefCompounds;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $aliasFile = $self->getParamValue('aliasFile');

  my $extDbName = $self->getParamValue('extDbName');

  my $extDbReleaseNumber = $self->getParamValue('extDbVersion');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--aliasFile '$workflowDataDir/$aliasFile' --extDbName $extDbName --extDbReleaseNumber $extDbReleaseNumber";


  $self->testInputFile('aliasFile', "$workflowDataDir/$aliasFile");

   $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertDbRefCompounds", $args);


}

1;
