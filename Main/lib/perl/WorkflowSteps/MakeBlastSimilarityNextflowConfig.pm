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
    my $seqFile = $self->getParamValue("seqFile");
    my $preConfiguredDatabase = $self->getParamValue("preConfiguredDatabase");
    my $databaseDir = $self->getParamValue("databaseDir");
    my $databaseBaseName = $self->getParamValue("databaseBaseName");
    my $databaseFasta = $self->getParamValue("databaseFasta");
    my $databaseType = $self->getParamValue("databaseType");
    my $dataFile = $self->getParamValue("dataFile");
    my $logFile = $self->getParamValue("logFile");
    my $saveAllBlastFiles = $self->getParamValue("saveAllBlastFiles");
    my $saveGoodBlastFiles = $self->getParamValue("saveGoodBlastFiles");
    my $doNotParse = $self->getParamValue("doNotParse");
    my $printSimSeqsFile = $self->getParamValue("printSimSeqsFile");
    my $blastParamsFile = $self->getParamValue("blastParamsFile");
    my $fastaSubsetSize = $self->getParamValue("fastaSubsetSize");
    my $pValCutoff = $self->getParamValue("pValCutoff");
    my $lengthCutoff = $self->getParamValue("lengthCutoff");
    my $percentCutoff = $self->getParamValue("percentCutoff");
    my $outputType = $self->getParamValue("outputType");
    my $adjustMatchLength = $self->getParamValue("adjustMatchLength");
 
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
  saveAllBlastFiles = $saveAllBlastFiles 
  saveGoodBlastFiles = $saveGoodBlastFiles
  doNotParse = $doNotParse
  printSimSeqsFile = $printSimSeqsFile
  blastParamsFile = \"$blastParamsFile\"
  fastaSubsetSize = $fastaSubsetSize
  pValCutoff = $pValCutoff 
  lengthCutoff = $lengthCutoff
  percentCutoff = $percentCutoff
  outputType = \"$outputType\"
  adjustMatchLength = $adjustMatchLength

}
process {
  container = 'veupathdb/blastsimilarity'
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
