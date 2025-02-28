package ApiCommonWorkflow::Main::WorkflowSteps::CopyAndUncompressPeripheralCacheDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $peripheralCacheDir = join("/",$self->getSharedConfig('preprocessedDataCache'),"OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/peripheralCacheDir.tar.gz");
  my $outputDir = join("/", $workflowDataDir, $self->getParamValue("outputDir"));

  if ($undo) {
      $self->runCmd(0, "rm -rf $outputDir/peripheralCacheDir");
  }
  elsif ($test) {
      $self->runCmd(0, "mkdir $outputDir/peripheralCacheDir");
  }
  else {
      $self->runCmd(0, "cp ${peripheralCacheDir} $outputDir/peripheralCacheDir.tar.gz");
      $self->runCmd(0, "tar -xzf $outputDir/peripheralCacheDir.tar.gz -C $outputDir");
      $self->runCmd(0, "rm $outputDir/peripheralCacheDir.tar.gz");
      die "$outputDir/peripheralCacheDir does not exist" unless(-e "$outputDir/peripheralCacheDir");
  }
}

1;
