package ApiCommonWorkflow::Main::WorkflowSteps::MakeDnaSeqNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use GUS::ObjRelP::DbiDatabase;
use GUS::Supported::GusConfig;
use CBIL::Util::PropertySet;

sub run {
    my ($self, $test, $undo) = @_;

    my $workingDirRelativePath = $self->getParamValue("workingDirRelativePath");

    my $sampleSheetFile        = $self->getParamValue("sampleSheetFile");
    my $genomeFile             = $self->getParamValue("genomeFile");
    my $gtfFile                = $self->getParamValue("gtfFile");
    my $footprintFile          = $self->getParamValue("footprintFile");
    my $ploidy                 = $self->getParamValue("ploidy");
    my $resultsDirectory       = $self->getParamValue("resultsDirectory");
    my $organismAbbrev         = $self->getParamValue("organismAbbrev");
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
    my $maxNumberOfReads        = $self->getConfig("maxNumberOfReads");
    my $trimmomaticAdaptorsFile = $self->getConfig("trimmomaticAdaptorsFile");
    my $freebayesMinAltFraction = $self->getConfig("freebayesMinAltFraction");
    my $bwaThreads              = $self->getConfig("bwaThreads");

    my $executor = $self->getClusterExecutor();
    my $queue    = $self->getClusterQueue();

    # Look up taxon_id from the database for this organism
    my $gusConfigFile = $ENV{GUS_HOME} . "/config/gus.config";
    die "Config file $gusConfigFile does not exist" unless -e $gusConfigFile;

    my @properties = ();
    my $gusConfig  = CBIL::Util::PropertySet->new($gusConfigFile, \@properties, 1);

    my $taxonSql = "select taxon_id from apidb.organism where abbrev = '$organismAbbrev'";

    my $db = GUS::ObjRelP::DbiDatabase->new(
        $gusConfig->{props}->{dbiDsn},
        $gusConfig->{props}->{databaseLogin},
        $gusConfig->{props}->{databasePassword},
        0, 0, 1,
        $gusConfig->{props}->{coreSchemaName}
    );

    my $dbh = $db->getQueryHandle();
    my $stmt = $dbh->prepare($taxonSql);
    $stmt->execute();

    my $taxonId;
    while (my @row = $stmt->fetchrow_array()) {
        $taxonId = $row[0];
    }

    if ($undo) {
        $self->runCmd(0, "rm -rf $nextflowConfigFile");
    } else {
        open(F, ">", $nextflowConfigFile) or die "$! :Can't open config file '$nextflowConfigFile' for writing";
        print F
"
params {
  samplesheet             = \"$digestedSampleSheet\"
  bwaThreads              = $bwaThreads
  minCoverage             = $minCoverage
  genomeFastaFile         = \"$digestedGenomeFile\"
  gtfFile                 = \"$digestedGtfFile\"
  footprintFile           = \"$digestedFootprintFile\"
  winLen                  = $winLen
  ploidy                  = $ploidy
  outputDir               = \"$digestedResultsDir\"
  trimmomaticAdaptorsFile = $trimmomaticAdaptorsFile
  freebayesMinAltFraction = $freebayesMinAltFraction
  maxNumberOfReads        = $maxNumberOfReads
  taxonId                 = \"$taxonId\"
  geneSourceIdOrthologFile = \"$digestedOrthologFile\"
  chrsForCalcFile         = \"$digestedChrsForCalcFile\"
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
