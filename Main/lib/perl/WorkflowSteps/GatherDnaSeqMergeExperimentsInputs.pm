package ApiCommonWorkflow::Main::WorkflowSteps::GatherDnaSeqMergeExperimentsInputs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
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

        my @resultsDirs = glob($inputDirGlob);

        for my $resultsDir (@resultsDirs) {
            next unless -d $resultsDir;

            my ($experimentName) = $resultsDir =~ m|/([^/]+)/dnaseqNextflow/|;
            next unless $experimentName;

            for my $file (glob("$resultsDir/*/*.vcf.gz")) {
                my $basename = (split('/', $file))[-1];
                $self->runCmd(0, "ln -sf $file $stagingDir/vcfs/${experimentName}_${basename}");
            }

            for my $file (glob("$resultsDir/*/*.coverage.bed.gz")) {
                my $basename = (split('/', $file))[-1];
                $self->runCmd(0, "ln -sf $file $stagingDir/coverage/${experimentName}_${basename}");
            }

            for my $file (glob("$resultsDir/*/*_consensus.fa.gz")) {
                my $basename = (split('/', $file))[-1];
                $self->runCmd(0, "ln -sf $file $stagingDir/consensus/${experimentName}_${basename}");
            }

            if (-f "$resultsDir/indels.tsv") {
                $self->runCmd(0, "ln -sf $resultsDir/indels.tsv $stagingDir/indels/${experimentName}_indels.tsv");
            }
        }
    }
}

1;
