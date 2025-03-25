package ApiCommonWorkflow::Main::WorkflowSteps::MakeDnaSeqSingleExperimentNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use GUS::ObjRelP::DbiDatabase;
use GUS::Supported::GusConfig;
use CBIL::Util::PropertySet;

sub run {
  my ($self, $test, $undo) = @_;

  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $input = join("/", $clusterWorkflowDataDir, $self->getParamValue("input"));
  my $geneSourceIdOrthologFile = join("/", $clusterWorkflowDataDir, $self->getParamValue("geneSourceIdOrthologFile"));
  my $chrsForCalcFile = join("/", $clusterWorkflowDataDir, $self->getParamValue("chrsForCalcFile"));
  my $fromBAM = $self->getParamValue("fromBAM");
  my $isLocal= $self->getParamValue("isLocal");
  my $isPaired = $self->getParamValue("isPaired");
  my $analysisDir = $self->getParamValue("analysisDir");
  my $genomeFastaFile = join("/", $clusterWorkflowDataDir, $self->getParamValue("genomeFastaFile"));
  my $gtfFile = join("/", $clusterWorkflowDataDir, $self->getParamValue("gtfFile"));
  my $clusterResultDir = join("/", $clusterWorkflowDataDir, $self->getParamValue("clusterResultDir"));
  my $configFileName = $self->getParamValue("configFileName");
  my $ploidy = $self->getParamValue("ploidy");
  my $organismAbbrev = $self->getParamValue("organismAbbrev");
  my $footprintFile = join("/", $clusterWorkflowDataDir, $self->getParamValue("footprintFile"));
  my $configPath = join("/", $self->getWorkflowDataDir(),  $self->getParamValue("analysisDir"), $self->getParamValue("configFileName"));
  my $hisat2Threads = $self->getConfig("hisat2Threads");
  my $samtoolsThreads = $self->getConfig("samtoolsThreads");
  my $minCoverage = $self->getConfig("minCoverage");
  my $winLen = $self->getConfig("winLen");
  my $varscanPValue = $self->getConfig("varscanPValue");
  my $varscanMinVarFreqSnp = $self->getConfig("varscanMinVarFreqSnp");
  my $varscanMinVarFreqCons = $self->getConfig("varscanMinVarFreqCons");
  my $maxNumberOfReads = $self->getConfig("maxNumberOfReads");
  my $hisat2Index = $self->getConfig("hisat2Index");
  my $createIndex = $self->getConfig("createIndex");
  my $trimmomaticAdaptorsFile = $self->getConfig("trimmomaticAdaptorsFile");  
  my $ebiFtpUser = $self->getConfig("ebiFtpUser");  
  my $ebiFtpPassword = $self->getConfig("ebiFtpPassword");  

  my $executor = $self->getClusterExecutor();
  my $queue = $self->getClusterQueue();

  my $gusConfigFile = $ENV{GUS_HOME}."/config/gus.config";
  die "Config file $gusConfigFile does not exist" unless -e $gusConfigFile;

  my @properties = ();
  my $gusConfig = CBIL::Util::PropertySet -> new ($gusConfigFile, \@properties, 1);

  my $taxonSql = "select taxon_id from apidb.organism where abbrev = '$organismAbbrev'";

  my $db = GUS::ObjRelP::DbiDatabase-> new($gusConfig->{props}->{dbiDsn},
					   $gusConfig->{props}->{databaseLogin},
					   $gusConfig->{props}->{databasePassword},
                                         0,0,1, # verbose, no insert, default
					   $gusConfig->{props}->{coreSchemaName});

  my $dbh = $db->getQueryHandle();

  my $taxonStmt = $dbh->prepare($taxonSql);
  $taxonStmt->execute();

  my $taxonId;

  while (my @row = $taxonStmt->fetchrow_array()){
      $taxonId = $row[0];
  }

  if ($undo) {
    $self->runCmd(0,"rm -rf $configPath");
  } else {
    open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";

    print F
"
params {
  input = \"$input\"
  fromBAM = $fromBAM
  hisat2Threads = $hisat2Threads
  isPaired = $isPaired
  local = $isLocal
  organismAbbrev = \"$organismAbbrev\"
  minCoverage = $minCoverage
  genomeFastaFile = \"$genomeFastaFile\"
  gtfFile = \"$gtfFile\"
  footprintFile = \"$footprintFile\"
  winLen = $winLen 
  ploidy= $ploidy
  hisat2Index = $hisat2Index
  createIndex = $createIndex
  outputDir = \"$clusterResultDir\"
  trimmomaticAdaptorsFile = $trimmomaticAdaptorsFile
  varscanPValue = $varscanPValue
  varscanMinVarFreqSnp = $varscanMinVarFreqSnp
  varscanMinVarFreqCons = $varscanMinVarFreqCons
  maxNumberOfReads = $maxNumberOfReads
  taxonId = \"$taxonId\"
  geneSourceIdOrthologFile = \"$geneSourceIdOrthologFile\"
  chrsForCalcFile = \"$chrsForCalcFile\"
}

process {
  executor = \'$executor\'
  queue = \'$queue\'
  withName: 'gatk' {
    errorStrategy = { task.exitStatus in 130..140 ? 'retry' : 'finish' }
    maxRetries = 2
    clusterOptions = { task.attempt == 1 ?
      '-M 12000 -R \"rusage [mem=12000] span[hosts=1]\"'
      : '-M 18000 -R \"rusage [mem=18000] span[hosts=1]\"'
    }
  }
}

singularity {
  enabled = true
  autoMounts = true
}
";
  close(F);
 }
}

1;

