package ApiCommonWorkflow::Main::WorkflowSteps::UpdateOrthoPeripheralPersistentCache;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $checkSumFile = join("/", $workflowDataDir, $self->getParamValue("checkSum"));
    my $newGroupsFile = join("/", $workflowDataDir, $self->getParamValue("newGroupsFile"));
    my $preprocessedDataCache = $self->getSharedConfig('preprocessedDataCache');

    my $nextflowWorkflow = $self->getParamValue("nextflowWorkflow");
    my $nextflowBranch = $self->getSharedConfig("${nextflowWorkflow}.branch");
    $nextflowWorkflow =~ s/\//_/g;

    if ($undo) {
	$self->runCmd(0, "echo 'undo'");
    }
    elsif ($test) {
	$self->runCmd(0, "echo 'test'");
    }
    else {

      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/newPeripheralDiamondCache/  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/peripheralCacheDir");

      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/buildVersion.txt  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/residualBuildVersion.txt");

      $self->runCmd(0, "cp $newGroupsFile ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/newGroups.txt");      

      $self->runCmd(0, "cp -r $checkSumFile ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/checkSum.tsv");

      $self->runCmd(0, "rm -rf ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/");

      $self->runCmd(0, "rm ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/peripheralCacheDir.tar.gz");

      $self->runCmd(0, "tar -czf ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/peripheralCacheDir.tar.gz -C ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache peripheralCacheDir");

      $self->runCmd(0, "rm -rf ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/peripheralCacheDir");

    }
}

1;
