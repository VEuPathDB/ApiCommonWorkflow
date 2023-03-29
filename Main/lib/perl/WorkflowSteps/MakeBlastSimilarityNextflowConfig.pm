package ApiCommonWorkflow::Main::WorkflowSteps::MakeBlastSimilarityNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
    my $outputDir = join("/", $clusterWorkflowDataDir, $self->getParamValue("outputDir")); 
    my $configFileName = $self->getParamValue("configFileName");
    my $configPath = join("/", $workflowDataDir,  $self->getParamValue("analysisDir"), $self->getParamValue("configFileName"));
    my $blastProgram = $self->getParamValue("blastProgram");
    my $seqFile = join("/", $clusterWorkflowDataDir, $self->getParamValue("seqFile"));
    my $preConfiguredDatabase = $self->getParamValue("preConfiguredDatabase");
    my $databaseDir = $self->getParamValue("databaseDir");
    my $databaseBaseName = $self->getParamValue("databaseBaseName");
    my $databaseFasta = join("/", $clusterWorkflowDataDir, $self->getParamValue("databaseFasta"));
    my $databaseType = ($blastProgram =~ m/blastn|tblastx/i) ? 'nucl' : 'prot';
    my $dataFile = $self->getParamValue("dataFile");
    my $logFile = $self->getParamValue("logFile");
    my $printSimSeqsFile = $self->getParamValue("printSimSeqsFile");
    my $blastArgs = $self->getParamValue("blastArgs");
    my $fastaSubsetSize = $self->getParamValue("fastaSubsetSize");
    my $pValCutoff = $self->getParamValue("pValCutoff");
    my $lengthCutoff = $self->getParamValue("lengthCutoff");
    my $percentCutoff = $self->getParamValue("percentCutoff");
    my $outputType = $self->getParamValue("outputType");
    my $adjustMatchLength = $self->getParamValue("adjustMatchLength");
    my $increasedMemory = $self->getParamValue("increasedMemory");
    my $initialMemory = $self->getParamValue("initialMemory");
    my $maxForks = $self->getParamValue("maxForks");
    my $maxRetries = $self->getParamValue("maxRetries");

    my $executor = $self->getClusterExecutor();
    my $queue = $self->getClusterQueue();
 
    if ($undo) {
	$self->runCmd(0,"rm -rf $configPath");
    } else {
	open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";

    print F
"
params {
  blastProgram = \"$blastProgram\"
  seqFile = \"$seqFile\"
  preConfiguredDatabase = $preConfiguredDatabase
  databaseDir = \"$databaseDir\"
  databaseBaseName = \"$databaseBaseName\"
  databaseFasta = \"$databaseFasta\"
  databaseType = \"$databaseType\"
  dataFile = \"$dataFile\"
  logFile = \"$logFile\"
  outputDir = \"$outputDir\"
  printSimSeqsFile = $printSimSeqsFile
  blastArgs = \"$blastArgs\"
  fastaSubsetSize = $fastaSubsetSize
  pValCutoff = $pValCutoff 
  lengthCutoff = $lengthCutoff
  percentCutoff = $percentCutoff
  outputType = \"$outputType\"
  adjustMatchLength = $adjustMatchLength

}
process {
  container = \'veupathdb/blastsimilarity\'
  executor = \'$executor\'
  queue = \'$queue\'
  maxForks = $maxForks
  maxRetries = $maxRetries
  withName: \'blastSimilarity\' {
    errorStrategy = { task.exitStatus in 130..140 ? \'retry\' : \'finish\' }
    clusterOptions = {
      (task.attempt > 1 && task.exitStatus in 130..140)
        ? \'-M $increasedMemory -R \"rusage [mem=$increasedMemory] span[hosts=1]\"\'
        : \'-M $initialMemory -R \"rusage [mem=$initialMemory] span[hosts=1]\"\'
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
