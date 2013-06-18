package ApiCommonWorkflow::Main::WorkflowSteps::InsertPathways;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $pathwaysFileDir = $self->getParamValue('pathwaysFileDir');

  my $imageFileDir = $self->getParamValue('imageFileDir');

  my $type = $self->getParamValue('type');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--pathwaysFileDir $workflowDataDir/$pathwaysFileDir --imageFileDir $workflowDataDir/$imageFileDir --format '$type'";

  if ($test) {
    $self->testInputFile('pathwaysFileDir', "$workflowDataDir/$pathwaysFileDir");
    $self->testInputFile('imageFileDir', "$workflowDataDir/$imageFileDir");
  }

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertPathways", $args);

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

