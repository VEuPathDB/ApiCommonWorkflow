package ApiCommonWorkflow::Main::WorkflowSteps::CreatePeripheralOutdatedOrganisms;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $preprocessedDataCache = $self->getSharedConfig('preprocessedDataCache');
  my $cachedCheckSumFile = join("/", $preprocessedDataCache,"OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/checkSum.tsv");
  my $checkSumFile = join("/", $workflowDataDir, $self->getParamValue("checkSum"));
  my $outdatedOrganismsFile = join("/", $workflowDataDir, $self->getParamValue("outdatedOrganisms"));

  if ($undo) {
      $self->runCmd(0, "rm $outdatedOrganismsFile");
  }
  elsif ($test) {
      $self->runCmd(0, "touch $outdatedOrganismsFile");
  }
  else {
      $self->runCmd(0, "createOutdatedOrganismsFile --new $checkSumFile --old $cachedCheckSumFile --output $outdatedOrganismsFile");
  }
}

1;
