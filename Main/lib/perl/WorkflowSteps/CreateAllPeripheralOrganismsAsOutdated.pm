package ApiCommonWorkflow::Main::WorkflowSteps::CreateAllPeripheralOrganismsAsOutdated;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use File::Basename;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

# When core changes but peripheral proteomes are identical to the last run,
# checkBuildVersionCreatePeripheralOutdatedOrganisms creates doNotDoAnalysis
# instead of outdated.txt. In that case all organisms still need to be
# re-blasted against the new core groups, so this step creates outdated.txt
# listing every organism in the peripheral fastas directory.
# If outdated.txt already exists (checksums differed), this step does nothing.

sub run {
    my ($self, $test, $undo) = @_;

    my $workflowDataDir       = $self->getWorkflowDataDir();
    my $fastasDir             = join("/", $workflowDataDir, $self->getParamValue("fastasDir"));
    my $outdatedOrganismsFile = join("/", $workflowDataDir, $self->getParamValue("outdatedOrganismsFile"));

    if ($undo) {
        $self->runCmd(0, "rm -f $outdatedOrganismsFile");
    }
    elsif ($test) {
        $self->runCmd(0, "echo 'test'");
    }
    else {
        return if -e $outdatedOrganismsFile;

        die "Fastas directory not found: $fastasDir" unless -d $fastasDir;

        my @fastas = glob("${fastasDir}/*.fasta");
        die "No fasta files found in $fastasDir" unless @fastas;

        open(my $fh, ">", $outdatedOrganismsFile) or die "Cannot write $outdatedOrganismsFile: $!";
        foreach my $fasta (@fastas) {
            my $abbrev = basename($fasta, ".fasta");
            print $fh "$abbrev\n";
        }
        close($fh);
    }
}

1;
