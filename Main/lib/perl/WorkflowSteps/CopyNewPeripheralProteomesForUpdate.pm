package ApiCommonWorkflow::Main::WorkflowSteps::CopyNewPeripheralProteomesForUpdate;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

# Diffs the current peripheral checkSum.tsv against the cached one and copies
# FASTA files for new or changed organisms into the update proteomes directory.
# Only these organisms are blasted against core in the update workflow.

sub run {
    my ($self, $test, $undo) = @_;

    my $workflowDataDir      = $self->getWorkflowDataDir();
    my $preprocessedDataCache = $self->getSharedConfig('preprocessedDataCache');

    my $currentCheckSum = join("/", $workflowDataDir, $self->getParamValue("currentCheckSum"));
    my $sourceFastasDir = join("/", $workflowDataDir, $self->getParamValue("sourceFastasDir"));
    my $outputDir       = join("/", $workflowDataDir, $self->getParamValue("outputDir"));
    my $cachedCheckSum  = "${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache/checkSum.tsv";

    if ($undo) {
        $self->runCmd(0, "rm -f ${outputDir}/*.fasta");
    }
    elsif ($test) {
        $self->runCmd(0, "echo 'test'");
    }
    else {
        die "Current checkSum not found: $currentCheckSum"   unless -e $currentCheckSum;
        die "Cached checkSum not found: $cachedCheckSum"     unless -e $cachedCheckSum;
        die "Source fastas dir not found: $sourceFastasDir"  unless -d $sourceFastasDir;
        die "Output dir not found: $outputDir"               unless -d $outputDir;

        my %cachedHashes;
        open(my $cached_fh, "<", $cachedCheckSum) or die "Cannot open $cachedCheckSum: $!";
        while (<$cached_fh>) {
            chomp;
            my ($hash, $abbrev) = split(/\s+/, $_, 2);
            $cachedHashes{$abbrev} = $hash;
        }
        close($cached_fh);

        my $copied = 0;
        open(my $current_fh, "<", $currentCheckSum) or die "Cannot open $currentCheckSum: $!";
        while (<$current_fh>) {
            chomp;
            my ($hash, $abbrev) = split(/\s+/, $_, 2);
            if (!exists $cachedHashes{$abbrev} || $cachedHashes{$abbrev} ne $hash) {
                my $fastaFile = "${sourceFastasDir}/${abbrev}.fasta";
                die "FASTA not found for organism '$abbrev': $fastaFile" unless -e $fastaFile;
                $self->runCmd(0, "cp $fastaFile ${outputDir}/");
                $copied++;
            }
        }
        close($current_fh);

        die "No new or changed peripheral organisms found. To force a re-run of all organisms, clear the cached checkSum: $cachedCheckSum" unless $copied;
    }
}

1;
