package ApiCommonWorkflow::Main::WorkflowSteps::CheckIfCoreHasChanged;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

# Compares the modification time of the core reformattedGroups.txt against a
# timestamp written to the official peripheral cache after each completed run.
# Creates exactly one sentinel file in outputDir:
#   coreHasChanged  — full pipeline should run
#   coreNotChanged  — update pipeline should run
# The sentinel files are consumed by skipIfFile on the two downstream subgraphs.

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir    = $self->getWorkflowDataDir();
  my $coreResultsDir     = $self->getParamValue("coreResultsDir");
  my $outputDir          = join("/", $workflowDataDir, $self->getParamValue("outputDir"));
  my $preprocessedDataCache = $self->getSharedConfig('preprocessedDataCache');

  my $officialCache      = "${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache";
  my $timestampFile      = "${officialCache}/lastPeripheralRunTimestamp";
  my $coreGroupsFile     = "${coreResultsDir}/reformattedGroups.txt";
  my $coreHasChangedFile = "${outputDir}/coreHasChanged";
  my $coreNotChangedFile = "${outputDir}/coreNotChanged";

  if ($undo) {
    $self->runCmd(0, "rm -f $coreHasChangedFile $coreNotChangedFile");
  }
  elsif ($test) {
    $self->runCmd(0, "echo 'test'");
  }
  else {
    die "Core reformattedGroups.txt not found at $coreGroupsFile" unless -e $coreGroupsFile;

    if (!-e $timestampFile) {
      # No record of a previous peripheral run — treat as first run
      $self->runCmd(0, "touch $coreHasChangedFile");
    }
    else {
      my $coreMtime  = (stat($coreGroupsFile))[9];
      my $cacheMtime = (stat($timestampFile))[9];

      if ($coreMtime > $cacheMtime) {
        $self->runCmd(0, "touch $coreHasChangedFile");
      }
      else {
        $self->runCmd(0, "touch $coreNotChangedFile");
      }
    }
  }
}

1;
