package ApiCommonWorkflow::Main::WorkflowSteps::MakeGSNAPTaskInputDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameter values
  my $readFilePath = $self->getParamValue("readFilePath");
  my $hasPairedEnds = $self->getBooleanParamValue("hasPairedEnds");
  my $limitNU = $self->getParamValue("limitNU");
  my $taskInputDir = $self->getParamValue("taskInputDir");
  my $strandSpecific = $self->getParamValue("strandSpecific");
  my $keepNode = $self->getParamValue("keepNode");
  my $createJunctionsFile = $self->getParamValue("createJunctionsFile");
  my $spliceSitesDatabase = $self->getParamValue("spliceSitesDatabase");
  my $gtfFile = $self->getParamValue("gtfFile");
  my $maskFile = $self->getParamValue("maskFile");
  my $topLevelGeneFootprintFile = $self->getParamValue("topLevelGeneFootprintFile");
  my $topLevelFastaFile = $self->getParamValue("topLevelFastaFile");
  my $gmapDatabase = $self->getParamValue("gmapDatabase");
  my $gsnapDirectory = $self->getParamValue("gsnapDirectory");
  my $quantify = $self->getParamValue("quantify");
  my $writeCovFiles = $self->getParamValue("writeCovFiles");
  my $clusterServer = $self->getSharedConfig('clusterServer');
  my $taskSize = $self->getConfig("taskSize");

#  my $blatExec = $self->getConfig("$clusterServer.blatExec");
 # my $mdustExec = $self->getConfig("$clusterServer.mdustExec");

  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $workflowDataDir = $self->getWorkflowDataDir();


  if ($undo) {
    $self->runCmd(0, "rm -rf $workflowDataDir/$taskInputDir/");
  }else {

    $self->testInputFile('readFilePath', "$workflowDataDir/$readFilePath");
    # todo: test more inputs


      $self->runCmd(0,"mkdir -p $workflowDataDir/$taskInputDir");

      # make controller.prop file
      $self->makeDistribJobControllerPropFile($taskInputDir, 1, $taskSize,
				       "DJob::DistribJobTasks::GSNAPTask", $keepNode); 
      # make task.prop file
      my $taskPropFile = "$workflowDataDir/$taskInputDir/task.prop";
      open(F, ">$taskPropFile") || die "Can't open task prop file '$taskPropFile' for writing";

      my $taskPropFileContent="
mateA=$clusterWorkflowDataDir/$readFilePath
genomeDatabase=$clusterWorkflowDataDir/$gsnapDirectory/$gmapDatabase
gtfFile=$clusterWorkflowDataDir/$gsnapDirectory/$gtfFile
maskFile=$clusterWorkflowDataDir/$gsnapDirectory/$maskFile
iitFile=$clusterWorkflowDataDir/$gsnapDirectory/$spliceSitesDatabase
nPaths=$limitNU
quantify=$quantify
writeCovFiles=$writeCovFiles
isStrandSpecific=$strandSpecific
quantifyJunctions=$createJunctionsFile
topLevelGeneFootprintFile=$clusterWorkflowDataDir/$topLevelGeneFootprintFile
topLevelFastaFaiFile=$clusterWorkflowDataDir/$topLevelFastaFile.fai
";

      $taskPropFileContent .= "mateB=$clusterWorkflowDataDir/$readFilePath.paired\n" if($hasPairedEnds);

      print F "$taskPropFileContent\n";
       close(F);
  }
}

1;


