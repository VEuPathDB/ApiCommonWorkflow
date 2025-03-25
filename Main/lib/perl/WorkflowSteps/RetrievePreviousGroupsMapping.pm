package ApiCommonWorkflow::Main::WorkflowSteps::RetrievePreviousGroupsMapping;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $previousGroups = join("/",$self->getSharedConfig('preprocessedDataCache'),"OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/previousGroups.txt");
  my $outputDir = join("/", $workflowDataDir, $self->getParamValue("outputDir"));

  if ($undo) {
      $self->runCmd(0, "rm -rf $outputDir/previousGroups.txt");
  }
  elsif ($test) {
      $self->runCmd(0, "touch $outputDir/previousGroups.txt");
  }
  else {
      $self->runCmd(0, "cp $previousGroups $outputDir");
      die "$outputDir/previousGroups.txt does not exist" unless(-e "$outputDir/previousGroups.txt");
  }
}

1;
