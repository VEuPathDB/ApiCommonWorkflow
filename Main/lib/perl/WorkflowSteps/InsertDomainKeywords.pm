package ApiCommonWorkflow::Main::WorkflowSteps::InsertDomainKeywords;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $groupTypesCPR = $self->getParamValue('groupTypesCPR');
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = " --groupTypesCPR $groupTypesCPR";

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertGroupDomains", $args);

}
