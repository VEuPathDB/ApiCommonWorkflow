package ApiCommonWorkflow::Main::WorkflowSteps::InsertPubChemCompounds;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $fileDir = $self->getParamValue('fileDir');

  my $fileNames = $self->getParamValue('fileNames');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--fileDir $workflowDataDir/$fileDir --fileNames '$fileNames' ";


  if ($test) {
    $self->testInputFile('fileDir', "$workflowDataDir/$fileDir");
    $self->testInputFile('fileNames', "$workflowDataDir/$fileNames");
  }

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertPubChemCompounds", $args);

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

