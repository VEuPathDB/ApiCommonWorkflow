package ApiCommonWorkflow::Main::WorkflowSteps::MakeDnaSeqNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $workingDirRelativePath = $self->getParamValue("workingDirRelativePath");

    my $sampleSheetFile        = $self->getParamValue("sampleSheetFile");
    my $genomeFile             = $self->getParamValue("genomeFile");
    my $gtfFile                = $self->getParamValue("gtfFile");
    my $footprintFile          = $self->getParamValue("footprintFile");
    my $ploidy                 = $self->getParamValue("ploidy");
    my $resultsDirectory       = $self->getParamValue("resultsDirectory");
    my $geneSourceIdOrthologFile = $self->getParamValue("geneSourceIdOrthologFile");
    my $chrsForCalcFile        = $self->getParamValue("chrsForCalcFile");

    my $nextflowConfigFile = $self->getWorkflowDataDir() . "/" . $self->getParamValue("nextflowConfigFile");

    # Translate local paths to cluster-side paths
    my $digestedSampleSheet      = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $sampleSheetFile);
    my $digestedGenomeFile       = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $genomeFile);
    my $digestedGtfFile          = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $gtfFile);
    my $digestedFootprintFile    = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $footprintFile);
    my $digestedResultsDir       = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $resultsDirectory);
    my $digestedOrthologFile     = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $geneSourceIdOrthologFile);
    my $digestedChrsForCalcFile  = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $chrsForCalcFile);

    # Workflow config values
    my $minCoverage             = $self->getConfig("minCoverage");
    my $winLen                  = $self->getConfig("winLen");
    my $bwaThreads              = $self->getConfig("bwaThreads");

    my $executor        = $self->getClusterExecutor();
    my $queue           = $self->getClusterQueue();

    my $genomeFastaFile = $self->getWorkflowDataDir() . "/" . $self->getParamValue("genomeFastaFile");

    my $genomeSizeBytes = 0;
    if (defined($genomeFastaFile) && -e $genomeFastaFile) {
        open(my $fh, "<", $genomeFastaFile) or die "Cannot open genome fasta '$genomeFastaFile': $!";
        while (<$fh>) {
            next if /^>/;
            chomp;
            $genomeSizeBytes += length($_);
        }
        close($fh);
    }

    if ($undo) {
        $self->runCmd(0, "rm -rf $nextflowConfigFile");
    } else {
        open(F, ">", $nextflowConfigFile) or die "$! :Can't open config file '$nextflowConfigFile' for writing";
        print F "
params {
  samplesheet              = \"$digestedSampleSheet\"
  bwaThreads               = $bwaThreads
  minCoverage              = $minCoverage
  genomeFastaFile          = \"$digestedGenomeFile\"
  gtfFile                  = \"$digestedGtfFile\"
  footprintFile            = \"$digestedFootprintFile\"
  winLen                   = $winLen
  ploidy                   = $ploidy
  outputDir                = \"$digestedResultsDir\"
  geneSourceIdOrthologFile = \"$digestedOrthologFile\"
  chrsForCalcFile          = \"$digestedChrsForCalcFile\"
  genomeSize               = $genomeSizeBytes
}

process {
  executor = '$executor'
  queue    = '$queue'
}

singularity {
  enabled    = true
  autoMounts = true
}
";
        close(F);
    }
}

1;
