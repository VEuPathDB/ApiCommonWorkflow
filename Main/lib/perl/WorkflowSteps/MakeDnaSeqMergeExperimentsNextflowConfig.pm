package ApiCommonWorkflow::Main::WorkflowSteps::MakeDnaSeqMergeExperimentsNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use GUS::ObjRelP::DbiDatabase;
use GUS::Supported::GusConfig;
use CBIL::Util::PropertySet;

# --- TECHNICAL DEBT -------------------------------------------------------
# Ploidy is not a first-class organism attribute in the database, and the
# per-experiment ploidy is only visible inside the dataset-template scope of
# dnaseq.xml. As a workaround we read ploidy back out of the per-experiment
# nextflow configs this workflow already generated and require them to agree.
# This couples the merge step to MakeDnaSeqNextflowConfig.pm's output format.
# Correct long-term home: a ploidy column on apidb.organism.
# -------------------------------------------------------------------------
sub parsePloidyFromConfigs {
  my (@configFiles) = @_;
  die "No per-experiment nextflow config files found to read ploidy from\n"
    unless @configFiles;
  my %seen;
  for my $file (@configFiles) {
    open(my $fh, '<', $file) or die "Can't open experiment config '$file': $!";
    my $ploidy;
    while (my $line = <$fh>) {
      if ($line =~ /^\s*ploidy\s*=\s*(\S+)/) { $ploidy = $1; last; }
    }
    close $fh;
    die "No ploidy value found in experiment config '$file'\n" unless defined $ploidy;
    $seen{$ploidy} = 1;
  }
  my @values = sort keys %seen;
  die "Inconsistent ploidy across experiments (found: @values); refusing to merge\n"
    if @values > 1;
  return $values[0];
}

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $stagingDir      = join("/", $workflowDataDir, $self->getParamValue("stagingDir"));
  my $outputDir       = join("/", $workflowDataDir, $self->getParamValue("outputDir"));
  my $configPath      = join("/", $workflowDataDir, $self->getParamValue("analysisDir"), $self->getParamValue("configFileName"));
  my $gtfFile         = join("/", $workflowDataDir, $self->getParamValue("gtfFile"));
  my $genomeFastaFile = join("/", $workflowDataDir, $self->getParamValue("genomeFastaFile"));
  my $organismAbbrev  = $self->getParamValue("organismAbbrev");
  my $cacheFile       = join("/", $workflowDataDir, $self->getParamValue("cacheFile"));
  my $experimentConfigGlob = join("/", $workflowDataDir, $self->getParamValue("experimentConfigGlob"));

  my $gusConfigFile = $ENV{GUS_HOME}."/config/gus.config";
  die "Config file $gusConfigFile does not exist" unless -e $gusConfigFile;

  my @properties = ();
  my $gusConfig = CBIL::Util::PropertySet->new($gusConfigFile, \@properties, 1);

  my $referenceSql = "select REF_STRAIN_ABBREV from apidb.organism where abbrev = '$organismAbbrev'";
  my $db = GUS::ObjRelP::DbiDatabase->new($gusConfig->{props}->{dbiDsn},
                                          $gusConfig->{props}->{databaseLogin},
                                          $gusConfig->{props}->{databasePassword},
                                          0,0,1,
                                          $gusConfig->{props}->{coreSchemaName});
  my $dbh = $db->getQueryHandle();
  my $referenceStmt = $dbh->prepare($referenceSql);
  $referenceStmt->execute();
  my $referenceStrain;
  while (my @row = $referenceStmt->fetchrow_array()) { $referenceStrain = $row[0]; }

  if ($undo) {
    $self->runCmd(0, "rm -rf $configPath");
    return;
  }

  # ploidy is derived from the per-experiment configs (see parsePloidyFromConfigs).
  my @experimentConfigs = glob($experimentConfigGlob);
  my $ploidy = parsePloidyFromConfigs(@experimentConfigs);

  open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";
  print F
"
params {

  outputDir       = \"$outputDir\"
  cacheFile       = \"$cacheFile\"
  reference_strain = \'$referenceStrain\'
  genomeFastaFile = \"$genomeFastaFile\"
  gtfFile         = \"$gtfFile\"
  ploidy          = $ploidy
  relativeConsensusFilePattern = \"$stagingDir/consensus/*_consensus.fa.gz\"
  vcfFiles                     = \"$stagingDir/vcfs/*.vcf.gz\"
  indelsFiles                  = \"$stagingDir/indels/*.tsv\"
  coverageFiles                = \"$stagingDir/coverage/*.coverage.bed.gz\"

}

// Merge processes are singletons over collect()'d inputs (no per-sample scatter),
// so maxForks only gates the few independent early branches. Serialize them to
// keep peak memory flat (snpEff JVM, Julia processSeqVars).
process {
  maxForks = 1
}

singularity {
  enabled = true
  autoMounts = true
}
";
  close(F);
}

1;

