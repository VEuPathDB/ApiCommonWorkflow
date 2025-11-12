package ApiCommonWorkflow::Main::WorkflowSteps::InsertProductFromTabFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $gusConfigFile = $self->getParamValue('gusConfigFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");

  my $args = "--file $workflowDataDir/$inputFile"
    . " --organismAbbrev '$organismAbbrev'"
    . " --soGusConfigFile '$gusConfigFile'";

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertProductFromTabFile", $args);
}

1;
