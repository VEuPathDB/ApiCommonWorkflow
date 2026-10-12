package ApiCommonWorkflow::Main::WorkflowSteps::ComputeNextResidualBuildVersion;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

# postResidualEntry numbers every brand-new residual group it creates starting
# from OGR${buildVersion}r${residualBuildVersion}_0000001, using OrthoFinder's
# own internal sequential numbering for whatever pool it just clustered --
# with no awareness of residual group IDs created by any earlier run. That's
# fine for a full rebuild (postResidualEntry only ever runs once, nothing to
# collide with), but the incremental path reuses postResidualEntry every time
# it runs, and residualBuildVersion (normally a static, one-time-set shared
# config value) never changes between those runs -- so every incremental
# run's brand-new residual groups collide head-on with residual group IDs
# already created by the full rebuild (or an earlier incremental run).
#
# residualBuildVersion.txt is already tracked in the persistent cache (the
# full-rebuild writer has cached it from the start), it just was never read
# back and incremented. This step closes that loop: read the cached value,
# add 1, write it out for this run's postResidualEntry config to use instead
# of the static shared-config value -- so each run's brand-new residual
# groups land in their own untouched r${N} namespace.

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $cachedResidualBuildVersion = join("/", $workflowDataDir, $self->getParamValue("cachedResidualBuildVersion"));
  my $outputFile = join("/", $workflowDataDir, $self->getParamValue("outputFile"));

  if ($undo) {
    $self->runCmd(0, "rm -f $outputFile");
  }
  elsif ($test) {
    $self->runCmd(0, "echo 2 > $outputFile");
  }
  else {
    $self->testInputFile('cachedResidualBuildVersion', $cachedResidualBuildVersion);

    open(my $inFh, '<', $cachedResidualBuildVersion) || die "Could not open file $cachedResidualBuildVersion: $!";
    my $current = <$inFh>;
    close($inFh);
    chomp $current;
    $current =~ s/\s+//g;
    die "Cached residualBuildVersion '$current' in $cachedResidualBuildVersion is not a positive integer" unless $current =~ /^\d+$/ && $current > 0;

    my $next = $current + 1;

    open(my $outFh, '>', $outputFile) || die "Could not open file $outputFile for writing: $!";
    print $outFh "$next\n";
    close($outFh);
  }
}

1;
