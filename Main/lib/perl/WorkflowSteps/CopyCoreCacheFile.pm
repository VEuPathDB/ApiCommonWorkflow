package ApiCommonWorkflow::Main::WorkflowSteps::CopyCoreCacheFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

# Same purpose as CopyPeripheralCacheFile, but for the core OrthoMCL cache
# (OrthoMCL_coreGroups/officialDiamondCache) instead of the peripheral one --
# e.g. the core-only SpeciesIDs.txt, needed by the incremental path to
# distinguish core-organism from peripheral-organism sequences.

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $preprocessedDataCache = $self->getSharedConfig('preprocessedDataCache');

  my $fromFile = $self->getParamValue('fromFile');
  my $toFile = join("/", $workflowDataDir, $self->getParamValue('toFile'));
  my $fullFromFile = join("/", $preprocessedDataCache, "OrthoMCL/OrthoMCL_coreGroups/officialDiamondCache", $fromFile);

  if ($undo) {
    $self->runCmd(0, "rm -f $toFile");
  }
  elsif ($test) {
    $self->runCmd(0, "touch $toFile");
  }
  else {
    $self->runCmd(0, "cp $fullFromFile $toFile");
  }
}

1;
