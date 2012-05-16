package ApiCommonWorkflow::Main::WorkflowSteps::FindOrthomclPairs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $suffix = $self->getParamValue('suffix');


  my $configFile = "$workflowDataDir/orthomclPairs.config";
  my $logfile = "orthomclPairs.log";

  my $cmd = "orthomclPairs $configFile $logfile cleanup=no suffix";

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$logfile");
    $self->runCmd(0, "rm -f $workflowDataDir/$configFile");

    $self->runCmd($test, "executeIdSQL.pl --idSQL \"truncate table CoOrtholog$suffix\" ");
    $self->runCmd($test, "executeIdSQL.pl --idSQL \"truncate table Ortholog$suffix\" ");
    $self->runCmd($test, "executeIdSQL.pl --idSQL \"truncate table Inparalog$suffix\" ");
  } else {
      if ($test) {
	  $self->runCmd(0,"echo test > $workflowDataDir/$logfile");
      }

      $self->runCmd($test,$cmd);
  }
}
