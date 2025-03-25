package ApiCommonWorkflow::Main::WorkflowSteps::CopyAndUncompressCoreCacheDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $coreCacheDir = join("/",$self->getSharedConfig('preprocessedDataCache'),"OrthoMCL/OrthoMCL_coreGroups/officialDiamondCache/coreCacheDir.tar.gz");
  my $outputDir = join("/", $workflowDataDir, $self->getParamValue("outputDir"));

  if ($undo) {
      $self->runCmd(0, "rm -rf $outputDir/coreCacheDir");
  }
  elsif ($test) {
      $self->runCmd(0, "mkdir $outputDir/coreCacheDir");
  }
  else {
      $self->runCmd(0, "cp ${coreCacheDir} $outputDir/coreCacheDir.tar.gz");
      $self->runCmd(0, "tar -xzf $outputDir/coreCacheDir.tar.gz -C $outputDir");
      $self->runCmd(0, "rm $outputDir/coreCacheDir.tar.gz");
      die "$outputDir/coreCacheDir does not exist" unless(-e "$outputDir/coreCacheDir");
  }
}

1;
