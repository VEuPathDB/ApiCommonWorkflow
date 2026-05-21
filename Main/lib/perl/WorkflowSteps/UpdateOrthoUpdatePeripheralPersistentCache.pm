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

      $self->runCmd(0, "cp -r ${updateCache}/**/postUpdateEntryResults/bestRepsFull.fasta ${officialCache}/bestRepsFull.fasta");

      $self->runCmd(0, "cp -r ${updateCache}/**/postUpdateEntryResults/similar_groups.tsv ${officialCache}/similar_groups.tsv");

      $self->runCmd(0, "cp -r ${updateCache}/**/postUpdateEntryResults/ortho${orthoBuildVersion}db.dmnd ${officialCache}/");

      # mergedResidualBestReps.fasta becomes the new residualBestReps reference for future update runs
      $self->runCmd(0, "cp -r ${updateCache}/**/postUpdateEntryResults/mergedResidualBestReps.fasta ${officialCache}/residualBestReps.fasta");

      # mergedResidualFasta.fa (existing + new residuals) replaces residuals.fasta for future update runs
      $self->runCmd(0, "cp -r ${updateCache}/**/postUpdateEntryResults/mergedResidualFasta.fa ${officialCache}/residuals.fasta");

      # --- Files from updatePeripheralEntryResults ---

      $self->runCmd(0, "cp -r ${updateCache}/**/updatePeripheralEntryResults/GroupsFile.txt ${officialCache}/GroupsFile.txt");

      $self->runCmd(0, "cp -r ${updateCache}/**/updatePeripheralEntryResults/peripherals.fasta ${officialCache}/peripherals.fasta");

      $self->runCmd(0, "cp -r ${updateCache}/**/updatePeripheralEntryResults/fullProteome.fasta ${officialCache}/fullProteome.fasta");

      $self->runCmd(0, "rm -rf ${officialCache}/groupFastas");
      $self->runCmd(0, "cp -r ${updateCache}/**/updatePeripheralEntryResults/groupFastas ${officialCache}/");

      # Add newly computed blast results for new organisms into the existing peripheral cache
      $self->runCmd(0, "cp -r ${updateCache}/**/updatePeripheralEntryResults/newPeripheralDiamondCache/. ${officialCache}/peripheralCacheDir/");

      $self->runCmd(0, "mkdir -p ${officialCache}/groupStats");
      $self->runCmd(0, "cp -r ${updateCache}/**/updatePeripheralEntryResults/groupStats/updated_peripheral_stats.txt ${officialCache}/groupStats/");

      # --- Files from updateResidualEntryResults ---

      # updatedResidualGroups.txt (old OGRr1_* + new OGRr2_*) replaces reformattedGroups.txt
      $self->runCmd(0, "cp -r ${updateCache}/**/updateResidualEntryResults/updatedResidualGroups.txt ${officialCache}/reformattedGroups.txt");

      # Add new residual group fastas alongside existing ones
      $self->runCmd(0, "cp -r ${updateCache}/**/updateResidualEntryResults/residualGroupFastas/. ${officialCache}/residualGroupFastas/");

      $self->runCmd(0, "cp -r ${updateCache}/**/updateResidualEntryResults/groupStats/new_residual_stats.txt ${officialCache}/groupStats/");

      # Re-compress the peripheral diamond cache to include newly added organism blast results
      $self->runCmd(0, "tar -czf ${officialCache}/peripheralCacheDir.tar.gz -C ${officialCache} peripheralCacheDir");

      $self->runCmd(0, "rm -rf ${updateCache}");

      # Record completion time so CheckIfCoreHasChanged can detect future core changes
      $self->runCmd(0, "touch ${officialCache}/lastPeripheralRunTimestamp");

    }
}

1;
