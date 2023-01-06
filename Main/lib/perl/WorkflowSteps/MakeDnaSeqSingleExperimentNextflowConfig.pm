package ApiCommonWorkflow::Main::WorkflowSteps::MakeDnaSeqSingleExperimentNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $input = $self->getParamValue("input")
  my $fromBAM = $self->getParamValue("fromBAM")
  my $isLocal= $self->getParamValue("isLocal")
  my $isPaired = $self->getParamValue("isPaired") ? "paired" : "single";
  my $analysisDir = $self->getParamValue("analysisDir")
  my $genomeFastaFile = $self->getParamValue("genomeFastaFile")
  my $gtfFile = $self->getParamValue("gtfFile")
  my $clusterResultDir = $self->getParamValue("clusterResultDir")
  my $configFileName = $self->getParamValue("configFileName")
  my $ploidy = $self->getParamValue("ploidy")
  my $organismAbbrev = $self->getParamValue("organismAbbrev")
  my $footprintFile = $self->getParamValue("footprintFile")
  my $configPath = join("/", $self->getWorkflowDataDir(),  $self->getParamValue("analysisDir"), $self->getParamValue("configFileName"));
  my $clusterResultDir = join("/", $self->getClusterWorkflowDataDir(), $self->getParamValue("clusterResultDir"));
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

  if ($undo) {
    $self->runCmd(0,"rm -rf $configPath");
  } else {
    open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";

    print F
"
params {
  inputDir = \"$input\"
  fromBAM = $fromBAM
  hisat2Threads = $hisat2Threads
  isPaired = $isPaired
  isLocal = $isLocal
  organismAbbrev = \"$organismAbbrev\"
  minCoverage = $minCoverage
  genomeFastaFile = \"$genomeFastaFile\"
  gtfFile = \"$gtfFile\"
  footprintFile = \"$footprintFile\"
  winLen = $winLen 
  ploidy= $ploidy
  hisat2Index = \"$hisat4Index\"
  createIndex = $createIndex
  outputDir = \"$clusterResultDir\"
  trimmomaticAdaptorsFile = \"$trimmomaticAdaptorsFile\"
  varscanPValue = $varscanPvalue
  varscanMinVarFreqSnp = $varscanMinVarFreqSnp
  varscanMinVarFreqCons = $varscanMinVarFreqCons
  maxNumberOfReads = $maxNumberOfReads
}

 singularity {
     enabled = true
     runOptions = \"--user root\"
 }
";
  close(F);
 }
}

1;

