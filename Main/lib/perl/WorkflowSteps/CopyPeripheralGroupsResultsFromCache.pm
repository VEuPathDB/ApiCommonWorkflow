package ApiCommonWorkflow::Main::WorkflowSteps::CopyPeripheralGroupsResultsFromCache;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
 use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $preprocessedDataCache = $self->getSharedConfig('preprocessedDataCache');
  my $workflowDataDir = $self->getWorkflowDataDir();
  my $analysisDir = join("/", $workflowDataDir, $self->getParamValue("analysisDir"));

  if ($undo) {
      $self->runCmd(0, "echo 'undo'");
  }
  elsif ($test) {
      $self->runCmd(0, "echo 'test'");
  }
  else {

      # peripheralEntryResults
      $self->runCmd(0, "mkdir -p $analysisDir/peripheralEntryResults/");
      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/peripherals.fasta $analysisDir/peripheralEntryResults/");
      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/intraGroupBlastFile.tsv $analysisDir/peripheralEntryResults/");
      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/coreBestReps.txt $analysisDir/peripheralEntryResults/");
      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/GroupsFile.txt $analysisDir/peripheralEntryResults/");
      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/peripheralCacheDir.tar.gz $analysisDir/peripheralEntryResults/");
      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/residuals.fasta $analysisDir/peripheralEntryResults/");
      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/groupStats $analysisDir/peripheralEntryResults/");
      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/residuals.fasta $analysisDir/peripheralEntryResults/");
      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/groupFastas $analysisDir/peripheralEntryResults/");
      # postResidualEntryResults
      $self->runCmd(0, "mkdir -p $analysisDir/postResidualEntryResults/");
      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/groupStats $analysisDir/postResidualEntryResults/");
      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/residualBestReps.txt $analysisDir/postResidualEntryResults/");
      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/residualGroupFastas $analysisDir/postResidualEntryResults/");
      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/residualBuildVersion.txt $analysisDir/postResidualEntryResults/");
      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/intraResidualGroupBlastFile.tsv $analysisDir/postResidualEntryResults/");
      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/reformattedGroups.txt $analysisDir/postResidualEntryResults");
      # postProcessingEntryResults
      $self->runCmd(0, "mkdir -p $analysisDir/postProcessingEntryResults/");
      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/bestRepsFull.fasta $analysisDir/postProcessingEntryResults/");
      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/fullGroupFile.txt $analysisDir/postProcessingEntryResults/");
      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/similar_groups.tsv $analysisDir/postProcessingEntryResults/");
      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/ortho*db.dmnd $analysisDir/postProcessingEntryResults/");
      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/previousGroups.txt $analysisDir/postProcessingEntryResults/");
      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/geneTrees $analysisDir/postProcessingEntryResults/");

  }
}

1;
