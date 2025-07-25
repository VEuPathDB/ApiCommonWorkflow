package ApiCommonWorkflow::Main::WorkflowSteps::CopyAndUncompressPeripheralCacheDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $peripheralCacheDir = join("/",$self->getSharedConfig('preprocessedDataCache'),"OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/peripheralCacheDir.tar.gz");
  my $outputDir = $self->getParamValue("outputDir");
  my $fullOutputDir = join("/", $workflowDataDir, $self->getParamValue("outputDir"));

  if ($undo) {
      $self->runCmd(0, "rm -rf $fullOutputDir/peripheralCacheDir");
  }
  elsif ($test) {
      $self->runCmd(0, "mkdir $fullOutputDir/peripheralCacheDir");
  }
  else {
      $self->runCmd(0, "cp ${peripheralCacheDir} $fullOutputDir/peripheralCacheDir.tar.gz");
      $self->runCmd(0, "tar -xzf $fullOutputDir/peripheralCacheDir.tar.gz -C $outputDir");
      $self->runCmd(0, "rm $fullOutputDir/peripheralCacheDir.tar.gz");
      die "$fullOutputDir/peripheralCacheDir does not exist" unless(-e "$fullOutputDir/peripheralCacheDir");
  }
}

1;
