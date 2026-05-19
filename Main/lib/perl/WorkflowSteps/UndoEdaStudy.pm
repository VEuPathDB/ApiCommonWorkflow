package ApiCommonWorkflow::Main::WorkflowSteps::UndoEdaStudy;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $extDbRlsSpec  = $self->getParamValue('extDbRlsSpec');
  my $gusConfigFile = $self->getParamValue('gusConfigFile');

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $logFile = "$workflowDataDir/undoEdaStudy.log";

  if ($undo) {
    $self->runCmd($test, "undoEdaStudy.pl --extDbRlsSpec '$extDbRlsSpec' --gusConfigFile $gusConfigFile");
    $self->runCmd(0, "rm -f $logFile");
  } else {
    $self->runCmd($test, "echo 'EDA study metadata loaded for $extDbRlsSpec' > $logFile");
  }
}

1;
