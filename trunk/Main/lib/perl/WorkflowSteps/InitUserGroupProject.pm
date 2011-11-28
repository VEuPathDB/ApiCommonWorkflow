package ApiCommonWorkflow::Main::WorkflowSteps::InitUserGroupProject;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # typically passed in from rootParams.prop
  my $projectName = $self->getParamValue('projectName');
  my $projectVersion = $self->getParamValue('projectVersionForDatabase');

  if ($undo) {
  } else {
      $self->runCmd($test, "insertUserProjectGroup --firstName dontcare --lastName dontcare --projectName $projectName --projectRelease $projectVersion --commit");
  }
}

sub getConfigDeclaration {
  return (
	 );
}

