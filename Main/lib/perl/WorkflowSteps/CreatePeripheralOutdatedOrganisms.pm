package ApiCommonWorkflow::Main::WorkflowSteps::CreatePeripheralOutdatedOrganisms;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $preprocessedDataCache = $self->getSharedConfig('preprocessedDataCache');
  my $cachedCheckSumFile = join("/", $preprocessedDataCache,"OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/checkSum.tsv");
  my $checkSumFile = join("/", $workflowDataDir, $self->getParamValue("checkSum"));
  my $outdatedOrganismsFile = join("/", $workflowDataDir, $self->getParamValue("outdatedOrganisms"));
  my $skipIfFile = join("/", $workflowDataDir, $self->getParamValue("skipIfFile"));
  my $residualBuildVersion = $self->getSharedConfig("residualBuildVersion");
  my $cachedResidualBuildVersionFile = join("/", $preprocessedDataCache,"OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/residualBuildVersion.txt");
  my $cachedResidualBuildVersion = `cat $cachedResidualBuildVersionFile`;

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
	  if ($cachedResidualBuildVersion != $residualBuildVersion) {
	      die "Cached residual build version $cachedResidualBuildVersion and new residual build version $residualBuildVersion are different even though the proteomes are the same\n";
	  }
	  $self->runCmd(0, "touch $skipIfFile");
      }
      else {
	  if ($cachedResidualBuildVersion eq $residualBuildVersion) {
	      die "Cached build version $cachedResidualBuildVersion and new build version $residualBuildVersion are identical even though the proteomes are different\n";
	  }
          $self->runCmd(0, "createOutdatedOrganismsFile --new $checkSumFile --old $cachedCheckSumFile --output $outdatedOrganismsFile");
      }
  }
}

1;
