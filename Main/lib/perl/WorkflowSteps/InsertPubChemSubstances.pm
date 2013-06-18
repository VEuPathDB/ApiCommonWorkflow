package ApiCommonWorkflow::Main::WorkflowSteps::InsertPubChemSubstances;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $fileDir = $self->getParamValue('fileDir');

  my $fileNames = $self->getParamValue('fileNames');

  my $compoundIdsFile = $self->getParamValue('compoundIdsFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--fileDir ${fileDir} --fileNames '{fileNames}' --compoundIdsFile '{compoundIdsFile}' ";


  if ($test) {
    $self->testInputFile('fileDir', "$workflowDataDir/$fileDir");
    $self->testInputFile('fileNames', "$workflowDataDir/$fileNames");
  }

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertPubChemSubstances", $args);

}

sub getParamDeclaration {
  return (
	  'pathwaysFileDir',
	  'imageFileDir',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

