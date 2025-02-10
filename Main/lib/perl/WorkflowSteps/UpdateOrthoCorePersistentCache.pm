package ApiCommonWorkflow::Main::WorkflowSteps::UpdateOrthoCorePersistentCache;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
 use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $preprocessedDataCache = $self->getSharedConfig('preprocessedDataCache');

  if ($undo) {
      $self->runCmd(0, "echo 'undo'");
  }
  elsif ($test) {
      $self->runCmd(0, "echo 'test'");
  }
  else {

      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_coreGroups/genesAndProteins/VEuPathDB_orthofinder-nextflow_main/**/diamondCache  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_coreGroups/officialDiamondCache/coreCacheDir");

      $self->runCmd(0, "cp ${preprocessedDataCache}/OrthoMCL/OrthoMCL_coreGroups/genesAndProteins/VEuPathDB_orthofinder-nextflow_main/**/buildVersion.txt  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_coreGroups/officialDiamondCache/buildVersion.txt");

      $self->runCmd(0, "cp ${preprocessedDataCache}/OrthoMCL/OrthoMCL_coreGroups/genesAndProteins/VEuPathDB_orthofinder-nextflow_main/**/checkSum.tsv  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_coreGroups/officialDiamondCache/checkSum.tsv");

      $self->runCmd(0, "rm -rf ${preprocessedDataCache}/OrthoMCL/OrthoMCL_coreGroups/genesAndProteins/");
      
      $self->runCmd(0, "rm ${preprocessedDataCache}/OrthoMCL/OrthoMCL_coreGroups/officialDiamondCache/coreCacheDir.tar.gz");

      $self->runCmd(0, "tar -czf ${preprocessedDataCache}/OrthoMCL/OrthoMCL_coreGroups/officialDiamondCache/coreCacheDir.tar.gz ${preprocessedDataCache}/OrthoMCL/OrthoMCL_coreGroups/officialDiamondCache/coreCacheDir");

  }
}

1;
