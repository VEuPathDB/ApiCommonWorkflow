package ApiCommonWorkflow::Main::WorkflowSteps::UpdateOrthoCorePersistentCache;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
 use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $preprocessedDataCache = $self->getSharedConfig('preprocessedDataCache');

  my $nextflowWorkflow = $self->getParamValue("nextflowWorkflow");
  my $nextflowBranch = $self->getSharedConfig("${nextflowWorkflow}.branch");
  $nextflowWorkflow =~ s/\//_/g;

  if ($undo) {
      $self->runCmd(0, "echo undo");
  }
  elsif ($test) {
      $self->runCmd(0, "echo 'test'");
  }
  else {
      $self->runCmd(0, "rm -rf ${preprocessedDataCache}/OrthoMCL/OrthoMCL_coreGroups/officialDiamondCache/*");
      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_coreGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/buildVersion.txt  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_coreGroups/officialDiamondCache/");
      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_coreGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/groupDiamondResults  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_coreGroups/officialDiamondCache/");
      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_coreGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/diamondCache  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_coreGroups/officialDiamondCache/");
      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_coreGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/reformattedGroups.txt  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_coreGroups/officialDiamondCache/");
      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_coreGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/diamondCache/SequenceIDs.txt  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_coreGroups/officialDiamondCache/");
      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_coreGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/diamondCache/SpeciesIDs.txt  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_coreGroups/officialDiamondCache/");

      $self->runCmd(0, "mv ${preprocessedDataCache}/OrthoMCL/OrthoMCL_coreGroups/officialDiamondCache/diamondCache  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_coreGroups/officialDiamondCache/coreCacheDir");

      $self->runCmd(0, "rm -rf ${preprocessedDataCache}/OrthoMCL/OrthoMCL_coreGroups/genesAndProteins/");
      
      $self->runCmd(0, "tar -czf ${preprocessedDataCache}/OrthoMCL/OrthoMCL_coreGroups/officialDiamondCache/coreCacheDir.tar.gz -C ${preprocessedDataCache}/OrthoMCL/OrthoMCL_coreGroups/officialDiamondCache coreCacheDir");

      $self->runCmd(0, "rm -rf ${preprocessedDataCache}/OrthoMCL/OrthoMCL_coreGroups/officialDiamondCache/coreCacheDir");

  }
}

1;
