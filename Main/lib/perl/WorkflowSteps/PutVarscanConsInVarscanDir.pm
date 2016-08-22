package ApiCommonWorkflow::Main::WorkflowSteps::PutVarscanConsInVarscanDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $varscanConsDir = $self->getParamValue('varscanConsDir');
  my $strain = $self->getParamValue('strain');
  my $mainResultDir = $self->getParamValue('mainResultDir');

  my $cmd = "ln -s $workflowDataDir/$mainResultDir/result.coverage.txt $workflowDataDir/$varscanConsDir/$strain.coverage.txt";

  my $undoCmd = "/bin/rm $workflowDataDir/$varscanConsDir/$strain.coverage.txt";

  if ($undo) {
    $self->runCmd(0, $undoCmd);
  } else {
    if ($test) {
      $self->runCmd(0,"echo $cmd > $workflowDataDir/$varscanConsDir/$strain.coverage.txt");
    }

    $self->testInputFile('coverage.txt', "$workflowDataDir/$mainResultDir/result.coverage.txt");
    $self->runCmd($test,$cmd);
  }
}


1;
