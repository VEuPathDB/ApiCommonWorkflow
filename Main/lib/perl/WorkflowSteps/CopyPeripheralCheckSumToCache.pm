package ApiCommonWorkflow::Main::WorkflowSteps::CopyPeripheralCheckSumToCache;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
 use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $preprocessedDataCache = $self->getSharedConfig('preprocessedDataCache');
  my $workflowDataDir = $self->getWorkflowDataDir();
  my $checkSumFile = join("/", $workflowDataDir, $self->getParamValue("checkSum"));

  if ($undo) {
      $self->runCmd(0, "echo 'undo'");
  }
  elsif ($test) {
      $self->runCmd(0, "echo 'test'");
  }
  else {

      $self->runCmd(0, "cp -r $checkSumFile  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/");

  }
}

1;
