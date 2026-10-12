package ApiCommonWorkflow::Main::WorkflowSteps::MakeIncrementalChangedProteomesDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $proteomesDir = join("/", $workflowDataDir, $self->getParamValue("proteomesDir"));
  my $outdatedFile = join("/", $workflowDataDir, $self->getParamValue("outdatedFile"));
  my $outputDir = join("/", $workflowDataDir, $self->getParamValue("outputDir"));

  my $preprocessedDataCache = $self->getSharedConfig('preprocessedDataCache');
  my $oldCheckSum = join("/", $preprocessedDataCache, "OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/checkSum.tsv");

  if ($undo) {
      $self->runCmd(0, "rm -rf $outputDir/changedOrNewProteomes.tar.gz");
      $self->runCmd(0, "rm -rf $outputDir/changedOrNewFastas");
  }
  elsif ($test) {
      $self->runCmd(0, "mkdir -p $outputDir/changedOrNewFastas");
      $self->runCmd(0, "echo 'test' > $outputDir/changedOrNewFastas/test.fasta");
      $self->runCmd(0, "tar -zcvf changedOrNewProteomes.tar.gz -C $outputDir changedOrNewFastas");
      $self->runCmd(0, "mv changedOrNewProteomes.tar.gz $outputDir/");
  }
  else {
      $self->runCmd(0, "rm -rf $outputDir/changedOrNewFastas");
      $self->runCmd(0, "mkdir -p $outputDir/changedOrNewFastas");

      $self->runCmd(0, "makeIncrementalChangedProteomesDir --proteomesDir $proteomesDir --outdatedFile $outdatedFile --oldCheckSum $oldCheckSum --outputDir $outputDir/changedOrNewFastas");

      $self->runCmd(0, "tar -zcvf changedOrNewProteomes.tar.gz -C $outputDir changedOrNewFastas");
      $self->runCmd(0, "mv changedOrNewProteomes.tar.gz $outputDir/");
  }
}

1;
