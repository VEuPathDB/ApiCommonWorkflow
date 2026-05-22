package ApiCommonWorkflow::Main::WorkflowSteps::UpdateOrthoUpdatePeripheralPersistentCache;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $newGroupsFile = join("/", $workflowDataDir, $self->getParamValue("newGroupsFile"));
    my $previousGroups = join("/", $workflowDataDir, $self->getParamValue("previousGroups"));
    my $preprocessedDataCache = $self->getSharedConfig('preprocessedDataCache');
    my $orthoBuildVersion = $self->getSharedConfig('buildVersion');

    my $nextflowWorkflow = $self->getParamValue("nextflowWorkflow");
    my $nextflowBranch = $self->getSharedConfig("${nextflowWorkflow}.branch");
    $nextflowWorkflow =~ s/\//_/g;

    my $updateCache = "${preprocessedDataCache}/OrthoMCL/OrthoMCL_updatePeripheralGroups/genesAndProteins/${nextflowWorkflow}_${nextflowBranch}";
    my $officialCache = "${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache";

    if ($undo) {
        $self->runCmd(0, "echo 'undo'");
    }
    elsif ($test) {
        $self->runCmd(0, "echo 'test'");
    }
    else {

      # --- Files from postUpdateEntryResults ---

      $self->runCmd(0, "cp $newGroupsFile ${officialCache}/fullGroupFile.txt");

      $self->runCmd(0, "cp $previousGroups ${officialCache}/previousGroups.txt");

      $self->runCmd(0, "cp -r ${updateCache}/**/bestRepsFull.fasta ${officialCache}/bestRepsFull.fasta");

      $self->runCmd(0, "cp -r ${updateCache}/**/similar_groups.tsv ${officialCache}/similar_groups.tsv");

      $self->runCmd(0, "cp -r ${updateCache}/**/ortho${orthoBuildVersion}db.dmnd ${officialCache}/");

      # bestReps.fasta from updateResidualEntry is the complete residual best reps
      # (all residuals were re-run, so this replaces the previous residualBestReps.fasta)
      $self->runCmd(0, "cp -r ${updateCache}/**/bestReps.fasta ${officialCache}/residualBestReps.fasta");

      # residualFasta.fa from updateResidualEntry is the complete residuals fasta
      # (includes existing + new residuals, replaces residuals.fasta entirely)
      $self->runCmd(0, "cp -r ${updateCache}/**/residualFasta.fa ${officialCache}/residuals.fasta");

      # --- Files from updatePeripheralEntryResults ---

      $self->runCmd(0, "cp -r ${updateCache}/**/GroupsFile.txt ${officialCache}/GroupsFile.txt");

      $self->runCmd(0, "cp -r ${updateCache}/**/peripherals.fasta ${officialCache}/peripherals.fasta");

      $self->runCmd(0, "cp -r ${updateCache}/**/fullProteome.fasta ${officialCache}/fullProteome.fasta");

      $self->runCmd(0, "rm -rf ${officialCache}/groupFastas");
      $self->runCmd(0, "cp -r ${updateCache}/**/groupFastas ${officialCache}/");

      # Add newly computed blast results for new organisms into the existing peripheral cache
      $self->runCmd(0, "cp -r ${updateCache}/**/newPeripheralDiamondCache/. ${officialCache}/peripheralCacheDir/");

      $self->runCmd(0, "mkdir -p ${officialCache}/groupStats");
      $self->runCmd(0, "cp -r ${updateCache}/**/groupStats/updated_peripheral_stats.txt ${officialCache}/groupStats/");

      # --- Files from updateResidualEntryResults ---

      # updatedResidualGroups.txt contains the complete re-versioned residual groups;
      # replaces reformattedGroups.txt so the next update run starts from a clean base
      $self->runCmd(0, "cp -r ${updateCache}/**/updatedResidualGroups.txt ${officialCache}/reformattedGroups.txt");

      # All residuals were re-run, so residualGroupFastas is fully replaced (not appended)
      $self->runCmd(0, "rm -rf ${officialCache}/residualGroupFastas");
      $self->runCmd(0, "cp -r ${updateCache}/**/residualGroupFastas ${officialCache}/");

      $self->runCmd(0, "cp -r ${updateCache}/**/groupStats/new_residual_stats.txt ${officialCache}/groupStats/");

      # Re-compress the peripheral diamond cache to include newly added organism blast results
      $self->runCmd(0, "tar -czf ${officialCache}/peripheralCacheDir.tar.gz -C ${officialCache} peripheralCacheDir");

      $self->runCmd(0, "rm -rf ${updateCache}");

      # Record completion time so CheckIfCoreHasChanged can detect future core changes
      $self->runCmd(0, "touch ${officialCache}/lastPeripheralRunTimestamp");

    }
}

1;
