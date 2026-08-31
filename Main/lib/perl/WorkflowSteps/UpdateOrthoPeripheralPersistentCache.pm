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

      # residual_stats.txt is already picked up by the groupStats/* copy above: in the full-rebuild
      # layout it lives at postResidualEntryResults/groupStats/residual_stats.txt (a sibling of
      # peripheralEntryResults/groupStats/), and bash's ** here is a single-level match, not
      # globstar -- but a single-level glob still expands across every sibling directory that
      # matches, so **/groupStats/* already reaches both. In the incremental layout there's no
      # postResidualEntryResults subdirectory at all (flat groupStats/ with all three stats files),
      # so a line hardcoding that path fails outright there. Previously had an explicit copy line
      # for this file assuming the wildcard didn't reach it; confirmed (via a live glob test) that
      # assumption was wrong even for the full-rebuild case, so it was just redundant there and
      # broken here -- removed.

      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/ortho${orthoBuildVersion}db.dmnd  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/");

      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/peripherals.fasta  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/");

      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/previousGroups.txt  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/");

      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/reformattedGroups.txt  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/");

      # proteinToOrganism.tsv is published into diamondCache/ (orthoFinderSetup's publishDir in
      # orthoFinder-nextflow), not at the entry-results top level -- needs the same diamondCache/
      # prefix used above for SequenceIDs.txt/SpeciesIDs.txt on the core side.
      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/diamondCache/proteinToOrganism.tsv  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/");

      # Needed as the "previous run" baseline proteome for the incremental build path
      # (extracting current sequences for touched groups without recomputing similarity
      # for groups whose membership didn't change).
      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/fullProteome.fasta  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/");

      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/residualBestReps.txt  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/");

      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/residuals.fasta  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/");

      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/similar_groups.tsv  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/");

      # geneTrees is only produced by postProcessingEntry (part of the full-rebuild chain --
      # createGeneTrees is never called from the incremental entry at all), so it genuinely
      # doesn't exist to copy on the incremental path -- tolerate that instead of hard-failing.
      $self->runCmd(0, "cp -r ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}/**/geneTrees  ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/ 2>/dev/null || true");

      $self->runCmd(0, "rm -rf ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/genesAndProteins/");

      $self->runCmd(0, "tar -czf ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/peripheralCacheDir.tar.gz -C ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache peripheralCacheDir");

      $self->runCmd(0, "rm -rf ${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/peripheralCacheDir");

    }
}

1;
