package ApiCommonWorkflow::Main::WorkflowSteps::ComputeGroupIdRenameMap;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

# For every group touched this run (OG or OGR alike -- identifyTouchedGroups doesn't
# distinguish) that's still a valid group, compute its new ID: same permanent numeric
# identity, subVersion bumped to this run's newly-computed value. Untouched groups are
# absent from the output map entirely, so RenameGroupIds leaves their lines byte-identical
# wherever it's applied. A touched group that dropped below the minimum group size is
# deliberately still present in touchedGroups.txt itself (mergeByGroupId.pl/mergeBestReps.pl
# need it there, to drop its cached rows with no fresh replacement) but is excluded here --
# updatedStableGroups is this run's comprehensive current-membership file, so a dissolved
# group's absence from it is exactly the signal computeGroupIdRenameMap uses to skip it,
# rather than compute a rename for a group that no longer exists anywhere.

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $touchedGroups = join("/", $workflowDataDir, $self->getParamValue("touchedGroups"));
  my $newSubVersionFile = join("/", $workflowDataDir, $self->getParamValue("newSubVersionFile"));
  my $updatedStableGroups = join("/", $workflowDataDir, $self->getParamValue("updatedStableGroups"));
  my $outputFile = join("/", $workflowDataDir, $self->getParamValue("outputFile"));

  if ($undo) {
    $self->runCmd(0, "rm -f $outputFile");
  }
  elsif ($test) {
    $self->runCmd(0, "echo test > $outputFile");
  }
  else {
    $self->testInputFile('touchedGroups', $touchedGroups);
    $self->testInputFile('newSubVersionFile', $newSubVersionFile);
    $self->testInputFile('updatedStableGroups', $updatedStableGroups);

    open(my $fh, '<', $newSubVersionFile) || die "Could not open file $newSubVersionFile: $!";
    my $newSubVersion = <$fh>;
    close($fh);
    chomp $newSubVersion;
    $newSubVersion =~ s/\s+//g;

    $self->runCmd(0, "computeGroupIdRenameMap --touchedGroups $touchedGroups --newSubVersion $newSubVersion --updatedStableGroups $updatedStableGroups --output $outputFile");
  }
}

1;
