package ApiCommonWorkflow::Main::WorkflowSteps::GatherDnaSeqMergeExperimentsInputs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;

use File::Basename; 

use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $inputDirGlob    = join("/", $workflowDataDir, $self->getParamValue("inputDirGlob"));
    my $stagingDir      = join("/", $workflowDataDir, $self->getParamValue("stagingDir"));

    if ($undo) {
        $self->runCmd(0, "rm -rf $stagingDir");
    }
    elsif ($test) {
        $self->runCmd(0, "echo 'test'");
    }
    else {
        $self->runCmd(0, "mkdir -p $stagingDir/vcfs $stagingDir/coverage $stagingDir/consensus $stagingDir/indels");

        # The merge pipeline keys every stream on the bare sample name embedded
        # in the file content (VCF genotype columns, indel strain column, FASTA
        # record ids) and, for coverage, on the file basename. Sample names must
        # therefore be unique across all experiments. We stage with the bare
        # basename (no experiment prefix) so the coverage column names match the
        # VCF sample names, and fail loudly if two experiments collide on a name
        # rather than let 'ln -sf' silently clobber one of them.
        my @streams = (
            { subDir => 'vcfs',      glob => '*/*.vcf.gz' },
            { subDir => 'coverage',  glob => '*/*_coverage.bed.gz' },
            { subDir => 'consensus', glob => '*/*_consensus.fa.gz' },
            { subDir => 'indels',    glob => '*/*_indels.tsv' },
        );

        my @resultsDirs = glob($inputDirGlob);

        # First pass: enumerate every file, map it to its staging target, and
        # detect name collisions before creating any symlinks.
        my @links;        # [ source, target ]
        my %seenBy;       # subDir => basename => experimentName
        my @collisions;

        for my $resultsDir (@resultsDirs) {
            next unless -d $resultsDir;

            my ($experimentName) = $resultsDir =~ m|/([^/]+)/dnaseqNextflow/|;
            next unless $experimentName;

            for my $stream (@streams) {
                my $subDir = $stream->{subDir};
                for my $file (glob("$resultsDir/$stream->{glob}")) {
                    my $basename = basename($file);
                    if (defined $seenBy{$subDir}{$basename}) {
                        push @collisions,
                          "  $subDir/$basename: experiments '$seenBy{$subDir}{$basename}' and '$experimentName'";
                    }
                    else {
                        $seenBy{$subDir}{$basename} = $experimentName;
                        push @links, [$file, "$stagingDir/$subDir/$basename"];
                    }
                }
            }
        }

        if (@collisions) {
            $self->error("Duplicate sample names across dnaseq merge experiment inputs; "
                . "sample names must be unique across experiments:\n"
                . join("\n", @collisions));
        }

        # Second pass: all names are unique, so create the symlinks.
        for my $link (@links) {
            $self->runCmd(0, "ln -sf $link->[0] $link->[1]");
        }
    }
}

1;
