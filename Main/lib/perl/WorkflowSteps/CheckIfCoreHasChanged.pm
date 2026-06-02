package ApiCommonWorkflow::Main::WorkflowSteps::CheckIfCoreHasChanged;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

# Compares the current core proteome checksum against the one stored in the
# official core cache after the last completed core run.
# Creates exactly one sentinel file in outputDir:
#   coreHasChanged  — full peripheral pipeline should run
#   coreNotChanged  — update peripheral pipeline should run
# The sentinel files are consumed by skipIfFile on the two downstream subgraphs.

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir       = $self->getWorkflowDataDir();
  my $coreCheckSum          = join("/", $workflowDataDir, $self->getParamValue("coreCheckSum"));
  my $outputDir             = join("/", $workflowDataDir, $self->getParamValue("outputDir"));
  my $preprocessedDataCache = $self->getSharedConfig('preprocessedDataCache');

  my $cachedCheckSum     = "${preprocessedDataCache}/OrthoMCL/OrthoMCL_coreGroups/officialDiamondCache/checkSum.tsv";
  my $coreHasChangedFile = "${outputDir}/coreHasChanged";
  my $coreNotChangedFile = "${outputDir}/coreNotChanged";

  if ($undo) {
    $self->runCmd(0, "rm -f $coreHasChangedFile $coreNotChangedFile");
  }
  elsif ($test) {
    $self->runCmd(0, "echo 'test'");
  }
  else {
    die "Core checkSum.tsv not found at $coreCheckSum" unless -e $coreCheckSum;

    if (!-e $cachedCheckSum) {
      # No cached core checksum — treat as first run
      $self->runCmd(0, "touch $coreHasChangedFile");
    }
    else {
      my $diff = system("diff -q $coreCheckSum $cachedCheckSum > /dev/null 2>&1");
      if ($diff == 0) {
        $self->runCmd(0, "touch $coreNotChangedFile");
      }
      else {
        $self->runCmd(0, "touch $coreHasChangedFile");
      }
    }
  }
}

1;
