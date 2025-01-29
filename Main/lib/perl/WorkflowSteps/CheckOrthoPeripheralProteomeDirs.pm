package ApiCommonWorkflow::Main::WorkflowSteps::CheckOrthoPeripheralProteomeDirs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $peripheralDir = join("/", $workflowDataDir, $self->getParamValue("orthoPeripheralDir"));

  if ($undo) {
      $self->runCmd(0, "rm -rf $peripheralDir/check.txt");
  }
  elsif ($test) {
      $self->runCmd(0, "echo 'test' > $peripheralDir/check.txt");
  }
  else {
      $self->runCmd(0, "echo 'done' > $peripheralDir/check.txt");
  }
}

1;
