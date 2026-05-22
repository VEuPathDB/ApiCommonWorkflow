package ApiCommonWorkflow::Main::WorkflowSteps::MapUpdateResultsToPeripheralDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

# Creates the peripheralGroups/analysisDir/ subdirectory structure expected by
# downstream steps, symlinking update workflow outputs into the conventional
# peripheral result paths so all downstream steps are path-agnostic.

sub run {
    my ($self, $test, $undo) = @_;

    my $workflowDataDir  = $self->getWorkflowDataDir();
    my $peripheralDir    = join("/", $workflowDataDir, $self->getParamValue("peripheralDir"));
    my $updateDir        = join("/", $workflowDataDir, $self->getParamValue("updatePeripheralDir"));
    my $buildVersion     = $self->getSharedConfig('buildVersion');

    my $periResults      = "$peripheralDir/analysisDir/peripheralEntryResults";
    my $postResidResults = "$peripheralDir/analysisDir/postResidualEntryResults";
    my $postProcResults  = "$peripheralDir/analysisDir/postProcessingEntryResults";

    my $updatePeriResults      = "$updateDir/analysisDir/updatePeripheralEntryResults";
    my $updateResidResults     = "$updateDir/analysisDir/updateResidualEntryResults";
    my $postUpdateResults      = "$updateDir/analysisDir/postUpdateEntryResults";

    if ($undo) {
        $self->runCmd(0, "rm -rf $periResults $postResidResults $postProcResults");
    }
    elsif ($test) {
        $self->runCmd(0, "echo 'test'");
    }
    else {
        $self->runCmd(0, "mkdir -p $periResults/groupStats");
        $self->runCmd(0, "mkdir -p $postResidResults/groupStats");
        $self->runCmd(0, "mkdir -p $postProcResults/geneTrees");

        # peripheralEntryResults
        $self->runCmd(0, "ln -sf $updatePeriResults/GroupsFile.txt                              $periResults/GroupsFile.txt");
        $self->runCmd(0, "ln -sf $updatePeriResults/intraGroupBlastFile.tsv                     $periResults/intraGroupBlastFile.tsv");
        $self->runCmd(0, "ln -sf $updatePeriResults/groupStats/updated_peripheral_stats.txt     $periResults/groupStats/peripheral_stats.txt");
        # core_stats.txt is unchanged (core has not changed); sourced from cache copy
        $self->runCmd(0, "ln -sf $updateDir/groupStats/core_stats.txt                          $periResults/groupStats/core_stats.txt");

        # postResidualEntryResults (updatedResidualGroups.txt maps to reformattedGroups.txt)
        $self->runCmd(0, "ln -sf $updateResidResults/updatedResidualGroups.txt                  $postResidResults/reformattedGroups.txt");
        $self->runCmd(0, "ln -sf $updateResidResults/intraResidualGroupBlastFile.tsv            $postResidResults/intraResidualGroupBlastFile.tsv");
        $self->runCmd(0, "ln -sf $updateResidResults/groupStats/new_residual_stats.txt          $postResidResults/groupStats/residual_stats.txt");

        # postProcessingEntryResults
        $self->runCmd(0, "ln -sf $postUpdateResults/fullGroupFile.txt                           $postProcResults/fullGroupFile.txt");
        $self->runCmd(0, "ln -sf $postUpdateResults/similar_groups.tsv                         $postProcResults/similar_groups.tsv");
        $self->runCmd(0, "ln -sf $postUpdateResults/previousGroups.txt                         $postProcResults/previousGroups.txt");
        $self->runCmd(0, "ln -sf $postUpdateResults/ortho${buildVersion}db.dmnd                $postProcResults/ortho${buildVersion}db.dmnd");
    }
}

1;
