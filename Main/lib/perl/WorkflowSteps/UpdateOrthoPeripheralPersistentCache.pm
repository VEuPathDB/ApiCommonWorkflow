package ApiCommonWorkflow::Main::WorkflowSteps::UpdateOrthoPeripheralPersistentCache;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $checkSumFile = join("/", $workflowDataDir, $self->getParamValue("checkSum"));
    my $newGroupsFile = join("/", $workflowDataDir, $self->getParamValue("newGroupsFile"));
    my $previousGroups = join("/", $workflowDataDir, $self->getParamValue("previousGroups"));
    my $preprocessedDataCache = $self->getSharedConfig('preprocessedDataCache');
    my $orthoBuildVersion = $self->getSharedConfig('buildVersion');

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

      $self->runCmd(0, "rm -rf ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/*");

      $self->runCmd(0, "cp $newGroupsFile ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/newGroups.txt");      

      $self->runCmd(0, "cp -r $checkSumFile ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/checkSum.tsv");

      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/groupFastas  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/");

      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/residualGroupFastas  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/");

      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/newPeripheralDiamondCache/  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/peripheralCacheDir");

      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/buildVersion.txt  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/residualBuildVersion.txt");

      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/bestRepsFull.fasta  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/");

      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/coreBestReps.txt  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/");

      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/fullGroupFile.txt  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/");

      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/GroupsFile.txt  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/");

      $self->runCmd(0, "mkdir -p ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/groupStats");
      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/groupStats/*  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/groupStats/");

      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/intraGroupBlastFile.tsv  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/");

      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/intraResidualGroupBlastFile.tsv  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/");

      # residual_stats.txt lives under postResidualEntryResults/groupStats/, a sibling of
      # peripheralEntryResults/groupStats/ (already swept by the groupStats/* copy above) --
      # named explicitly here rather than relying on that wildcard reaching a sibling path.
      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/postResidualEntryResults/groupStats/residual_stats.txt  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/groupStats/");

      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/ortho${orthoBuildVersion}db.dmnd  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/");

      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/peripherals.fasta  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/");

      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/previousGroups.txt  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/");

      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/reformattedGroups.txt  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/");

      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/proteinToOrganism.tsv  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/");

      # Needed as the "previous run" baseline proteome for the incremental build path
      # (extracting current sequences for touched groups without recomputing similarity
      # for groups whose membership didn't change).
      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/fullProteome.fasta  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/");

      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/residualBestReps.txt  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/");

      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/residuals.fasta  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/");

      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/similar_groups.tsv  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/");

      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/geneTrees  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/");

      $self->runCmd(0, "rm -rf ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/");

      $self->runCmd(0, "tar -czf ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/peripheralCacheDir.tar.gz -C ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache peripheralCacheDir");

      $self->runCmd(0, "rm -rf ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/peripheralCacheDir");

    }
}

1;
