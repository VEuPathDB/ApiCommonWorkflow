package ApiCommonWorkflow::Main::WorkflowSteps::FindOrthomclPairs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use OrthoMCLEngine::Main::Base;


sub run {
  my ($self, $test, $undo) = @_;

  # Warning: on restart, orthomclPairs reads the log file to see where to start

  my $suffix = $self->getParamValue('suffix');
  my $confFile = $self->getParamValue('configFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $configFile = "$workflowDataDir/$confFile";

  my $suf = $suffix? "suffix=$suffix" : "";

  my $cmd = "orthomclPairs $configFile orthomclPairs.log cleanup=yes $suf startAfter=useLog";

  if ($undo) {
    $self->runCmd($test, "mv orthomclPairs.log  orthoMclPairs.log.sv.$$");
    $self->runCmd($test, "orthomclPairs $configFile orthomclPairsUndo.log cleanup=all $suf");
  } else {
      $self->runCmd($test,$cmd);
  }
}
