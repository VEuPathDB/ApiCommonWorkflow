package ApiCommonWorkflow::Main::WorkflowSteps::ComputeGroupIdRenameMap;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

# For every group touched this run (OG or OGR alike -- identifyTouchedGroups doesn't
# distinguish), compute its new ID: same permanent numeric identity, subVersion bumped to
# this run's newly-computed value. Untouched groups are absent from the output map
# entirely, so RenameGroupIds leaves their lines byte-identical wherever it's applied.

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $touchedGroups = join("/", $workflowDataDir, $self->getParamValue("touchedGroups"));
  my $newSubVersionFile = join("/", $workflowDataDir, $self->getParamValue("newSubVersionFile"));
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

    open(my $fh, '<', $newSubVersionFile) || die "Could not open file $newSubVersionFile: $!";
    my $newSubVersion = <$fh>;
    close($fh);
    chomp $newSubVersion;
    $newSubVersion =~ s/\s+//g;

    $self->runCmd(0, "computeGroupIdRenameMap --touchedGroups $touchedGroups --newSubVersion $newSubVersion --output $outputFile");
  }
}

1;
