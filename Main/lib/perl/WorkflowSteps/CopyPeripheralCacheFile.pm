package ApiCommonWorkflow::Main::WorkflowSteps::CopyPeripheralCacheFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

# Copies a single file out of the shared, persistent peripheral OrthoMCL cache
# (which lives outside the workflow data dir, so it isn't copied to the
# cluster automatically the way files under the workflow data dir are) into
# the workflow data dir, so it travels to the cluster normally alongside
# everything else a nextflow entry point needs.
#
# fromFile may contain the literal token BUILDVERSION, which is substituted
# with the current shared buildVersion config value -- needed for artifacts
# like ortho<buildVersion>db.dmnd whose name isn't known until run time.

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $preprocessedDataCache = $self->getSharedConfig('preprocessedDataCache');
  my $buildVersion = $self->getSharedConfig('buildVersion');

  my $fromFile = $self->getParamValue('fromFile');
  $fromFile =~ s/BUILDVERSION/$buildVersion/;

  my $toFile = join("/", $workflowDataDir, $self->getParamValue('toFile'));
  my $fullFromFile = join("/", $preprocessedDataCache, "OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache", $fromFile);

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
