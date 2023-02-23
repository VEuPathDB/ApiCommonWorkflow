package ApiCommonWorkflow::Main::WorkflowSteps::MakeDnaSeqSingleExperimentNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;
 
  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $input = join("/", $clusterWorkflowDataDir, $self->getParamValue("input"));
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
}

process {
  executor = \'lsf\'
  queue = \'test\'
  withName: \'bedtoolsWindowed\' {
    errorStrategy = {
      if ( task.attempt < 4 ) {
        return \'retry\'
      } else {
        return \'finish\'
      }
  }
  maxRetries = 10
  maxForks = 5
  clusterOptions = {
      (task.attempt > 1 && task.exitStatus in 130..140)
        ? \'-M 12000 -R \"rusage [mem=12000] span[hosts=1]\"\'
        : \'-M 4000 -R \"rusage [mem=4000] span[hosts=1]\"\'
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

