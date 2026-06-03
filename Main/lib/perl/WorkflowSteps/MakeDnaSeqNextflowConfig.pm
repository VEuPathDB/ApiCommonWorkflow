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

    my $executor      = $self->getClusterExecutor();
    my $queue         = $self->getClusterQueue();
    my $maxMemoryGigs = eval { $self->getParamValue("maxMemoryGigs") };

    my $isLsf = lc($executor) eq 'lsf';

    # runFreebayes process block
    my $freebayesBlock = "  withName: 'runFreebayes' {\n";
    $freebayesBlock   .= "    maxRetries = 1\n";
    $freebayesBlock   .= "    errorStrategy = { task.exitStatus in 130..140 ? 'retry' : 'finish' }\n";
    if ($isLsf) {
        $freebayesBlock .= "    clusterOptions = {\n";
        $freebayesBlock .= "      (task.attempt > 1 && task.exitStatus in 130..140)\n";
        $freebayesBlock .= "        ? '-M 12000 -R \"rusage [mem=12000] span[hosts=1]\"'\n";
        $freebayesBlock .= "        : '-M 4000 -R \"rusage [mem=4000] span[hosts=1]\"'\n";
        $freebayesBlock .= "    }\n";
    }
    $freebayesBlock   .= "  }\n";

    # bwaMem process block
    my $bwaRetries = defined($maxMemoryGigs) ? 0 : 1;
    my $bwaBlock   = "  withName: 'bwaMem' {\n";
    $bwaBlock     .= "    maxRetries = $bwaRetries\n";
    if (!defined($maxMemoryGigs)) {
        $bwaBlock .= "    errorStrategy = { task.exitStatus in 130..140 ? 'retry' : 'finish' }\n";
    }
    if ($isLsf) {
        if (defined($maxMemoryGigs)) {
            my $memMb = int($maxMemoryGigs * 1024);
            $bwaBlock .= "    clusterOptions = '-M $memMb -R \"rusage [mem=$memMb] span[hosts=1]\"'\n";
        } else {
            $bwaBlock .= "    clusterOptions = {\n";
            $bwaBlock .= "      (task.attempt > 1 && task.exitStatus in 130..140)\n";
            $bwaBlock .= "        ? '-M 12000 -R \"rusage [mem=12000] span[hosts=1]\"'\n";
            $bwaBlock .= "        : '-M 4000 -R \"rusage [mem=4000] span[hosts=1]\"'\n";
            $bwaBlock .= "    }\n";
        }
    }
    $bwaBlock .= "  }\n";

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
}

process {
  executor = '$executor'
  queue    = '$queue'
$freebayesBlock
$bwaBlock
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
