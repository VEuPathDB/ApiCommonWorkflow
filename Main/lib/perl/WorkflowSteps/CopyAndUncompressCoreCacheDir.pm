package ApiCommonWorkflow::Main::WorkflowSteps::CopyAndUncompressCoreCacheDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $coreCacheDir = join("/",$self->getSharedConfig('preprocessedDataCache'),"OrthoMCL/OrthoMCL_coreGroups/genesAndProteins/VEuPathDB_orthofinder-nextflow_main/edf10030cc3d4c02164464ce41675f3b/diamondCache");
  my $outputDir = join("/", $workflowDataDir, $self->getParamValue("outputDir"));

  if ($undo) {
      $self->runCmd(0, "rm -rf $outputDir/coreCacheDir");
  }
  elsif ($test) {
      $self->runCmd(0, "mkdir $outputDir/coreCacheDir");
  }
  else {
      $self->runCmd(0, "cp -r ${coreCacheDir} $outputDir/coreCacheDir");
      die "$outputDir/coreCacheDir does not exist" unless(-e "$outputDir/coreCacheDir");
  }
}

1;
