package ApiCommonWorkflow::Main::WorkflowSteps::FilterGroupFileByPrefix;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

# Splits a combined "GROUPID: seq1 seq2 ..." group file by group-ID prefix
# (e.g. "OGR" for residual groups) -- same split convention used elsewhere
# in this pipeline (splitTouchedBestRepsByType.bash). invert="1" keeps every
# line NOT matching the prefix instead.

sub run {
    my ($self, $test, $undo) = @_;

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $inputFile = join("/", $workflowDataDir, $self->getParamValue("inputFile"));
    my $outputFile = join("/", $workflowDataDir, $self->getParamValue("outputFile"));
    my $prefix = $self->getParamValue("prefix");
    my $invert = $self->getParamValue("invert");

    if ($undo) {
        $self->runCmd(0, "rm -f $outputFile");
    }
    elsif ($test) {
        $self->runCmd(0, "echo test > $outputFile");
    }
    else {
        $self->testInputFile('inputFile', $inputFile);

        my $grepFlag = $invert ? "-v" : "";
        # No matches is a legitimate outcome (e.g. an incremental run with no
        # residual-group changes at all), not a failure -- grep exits 1 then.
        $self->runCmd(0, "grep $grepFlag \"^${prefix}\" $inputFile > $outputFile || true");
    }
}

1;
