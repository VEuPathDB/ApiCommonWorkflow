package ApiCommonWorkflow::Main::WorkflowSteps::InitDIYUserGroupProject;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

# run script:
# insertUserProjectGroup --verbose --projectRelease(reqd) --firstName(reqd) --lastName(reqd) --userName --gusConfigFile [$GUS_HOME/config/gus.config] --commit

sub run {
  my ($self, $test, $undo) = @_;

  # typically passed in from rootParams.prop
# my $projectName = $self->getParamValue('projectName');
# my $userName = $self->getParamValue('userName');
# my $groupName = $self->getParamValue('groupName');
# my $wfName = $self->getWorkflowConfig('name');
  my ($projectName, $projectRelease, $groupName, $userName) = qw/DIYPROJ DIYREL DIYGROUP joeuser/;

  if ($undo) {
  } else {
      $self->runCmd($test, "insertUserProjectGroup --firstName dontcare --lastName dontcare --groupName $groupName  --userName $userName --projectName $projectName --projectRelease $projectRelease --commit");
  }
}

1;
