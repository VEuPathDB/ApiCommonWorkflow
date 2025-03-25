package ApiCommonWorkflow::Main::WorkflowSteps::CopyCoreGroupsResultsFromCache;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
 use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $preprocessedDataCache = $self->getSharedConfig('preprocessedDataCache');

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $resultsDir = join("/", $workflowDataDir, $self->getParamValue("resultsDir"));

  if ($undo) {
      $self->runCmd(0, "rm -rf $resultsDir/*");
  }
  elsif ($test) {
      $self->runCmd(0, "echo 'test'");
  }
  else {

      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_coreGroups/officialDiamondCache/* $resultsDir/");

  }
}

1;
