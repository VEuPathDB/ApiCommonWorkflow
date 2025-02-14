package ApiCommonWorkflow::Main::WorkflowSteps::CopyAndUncompressPeripheralCacheDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $peripheralCacheDir = join("/",$self->getSharedConfig('preprocessedDataCache'),"OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/VEuPathDB_orthofinder-nextflow_main/edf10030cc3d4c02164464ce41675f3b/newPeripheralDiamondCache");
  my $outputDir = join("/", $workflowDataDir, $self->getParamValue("outputDir"));

  if ($undo) {
      $self->runCmd(0, "rm -rf $outputDir/peripheralCacheDir");
  }
  elsif ($test) {
      $self->runCmd(0, "mkdir $outputDir/peripheralCacheDir");
  }
  else {
      $self->runCmd(0, "cp -r ${peripheralCacheDir} $outputDir/peripheralCacheDir");
      die "$outputDir/peripheralCacheDir.tar.gz does not exist" unless(-e "$outputDir/peripheralCacheDir.tar.gz");
  }
}

1;
