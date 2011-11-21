package ApiCommonWorkflow::Main::WorkflowSteps::InitUserGroupProject;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get global properties
  my $projectVersion = $self->getParamValue('projectVersionForDatabase');

  if ($undo) {
  } else {
      $self->runCmd($test, "insertUserProjectGroup --firstName dontcare --lastName dontcare --projectRelease $projectVersion --commit");
  }
}

sub getParamsDeclaration {
  return (
	 );
}

sub getConfigDeclaration {
  return (
	 );
}

