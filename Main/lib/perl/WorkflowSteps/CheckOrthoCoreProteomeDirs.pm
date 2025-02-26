package ApiCommonWorkflow::Main::WorkflowSteps::CheckOrthoCoreProteomeDirs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $coreDir = join("/", $workflowDataDir, $self->getParamValue("orthoCoreDir"));

  if ($undo) {
      $self->runCmd(0, "rm -rf $coreDir/check.txt");
  }
  elsif ($test) {
      $self->runCmd(0, "echo 'test' > $coreDir/check.txt");
  }
  else {
      $self->runCmd(0, "echo 'done' > $coreDir/check.txt");
  }
}

1;
