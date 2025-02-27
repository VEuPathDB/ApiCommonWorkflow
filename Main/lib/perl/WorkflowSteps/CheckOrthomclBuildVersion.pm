package ApiCommonWorkflow::Main::WorkflowSteps::CheckOrthomclBuildVersion;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $preprocessedDataCache = $self->getSharedConfig('preprocessedDataCache');
  my $buildVersion = $self->getSharedConfig("buildVersion");
  my $cachedBuildVersionFile = join("/", $preprocessedDataCache,"OrthoMCL/OrthoMCL_coreGroups/officialDiamondCache/buildVersion.txt");
  my $cachedCheckSumFile = join("/", $preprocessedDataCache,"OrthoMCL/OrthoMCL_coreGroups/officialDiamondCache/checkSum.tsv");
  my $checkSumFile = join("/", $workflowDataDir, $self->getParamValue("checkSum"));
  my $outdatedOrganismsFile = join("/", $workflowDataDir, $self->getParamValue("outdatedOrganisms"));
  my $skipIfFile = join("/", $workflowDataDir, $self->getParamValue("skipIfFile"));
  my $cachedBuildVersion = `cat $cachedBuildVersionFile`;

  my $diff_result = `diff $cachedCheckSumFile $checkSumFile`;

  if ($undo) {
    $self->runCmd(0, "rm $outdatedOrganismsFile");
    if ($diff_result eq '') {
      $self->runCmd(0, "rm $skipIfFile");
    }
  }
  elsif ($test) {
    $self->runCmd(0, "touch $outdatedOrganismsFile");
  }
  else {

    if ($diff_result eq '') {
      if ($cachedBuildVersion != $buildVersion) {
        die "Cached build version $cachedBuildVersion and new build version $buildVersion are different even though the proteomes are the same\n";  
      }
      $self->runCmd(0, "touch $skipIfFile");
    }
    else {
      if ($cachedBuildVersion eq $buildVersion) {
        die "Cached build version $cachedBuildVersion and new build version $buildVersion are identical even though the proteomes are different\n";  
      }
      # Clearing peripheral cache as core has changed
      $self->runCmd(0, "rm -rf ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/peripheralCacheDir*");
      $self->runCmd(0, "mkdir ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/peripheralCacheDir");
      if (-e "${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/checkSum.tsv") {
          $self->runCmd(0, "rm ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/checkSum.tsv");
      }
      $self->runCmd(0, "touch ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/checkSum.tsv");
      $self->runCmd(0, "tar -czf ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/peripheralCacheDir.tar.gz ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/peripheralCacheDir");
      $self->runCmd(0, "rm -rf ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/peripheralCacheDir");
    }
    $self->runCmd(0, "createOutdatedOrganismsFile --new $checkSumFile --old $cachedCheckSumFile --output $outdatedOrganismsFile");  
  }

}


1;
