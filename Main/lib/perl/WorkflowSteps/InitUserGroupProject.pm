package ApiCommonWorkflow::Main::WorkflowSteps::InitUserGroupProject;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # typically passed in from rootParams.prop
  my $projectName = $self->getParamValue('projectName');
  my $projectVersion = $self->getParamValue('projectVersionForDatabase');
  my $wfName = $self->getWorkflowConfig('name');
  my $wfVersion = $self->getWorkflowConfig('version');

  $self->error("Error: in rootParams.prop projectName=$projectName but in workflow.prop name=$wfName. These two must be equal.") unless $projectName eq $wfName;
  $self->error("Error: in rootParams.prop projectVersionForDatabase=$projectVersion but in workflow.prop version=$wfVersion. These two must be equal.") unless $projectVersion eq $wfVersion;

  if ($undo) {
  } else {
      $self->runCmd($test, "insertUserProjectGroup --firstName dontcare --lastName dontcare --projectName $projectName --projectRelease $projectVersion --commit");
  }
}

sub getConfigDeclaration {
  return (
	 );
}

