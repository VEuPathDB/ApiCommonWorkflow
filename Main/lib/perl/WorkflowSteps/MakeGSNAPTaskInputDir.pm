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
  my $maskFile = $self->getParamValue("maskFile");
  my $topLevelGeneFootprintFile = $self->getParamValue("topLevelGeneFootprintFile");
  my $topLevelFastaFile = $self->getParamValue("topLevelFastaFile");
  my $gmapDatabase = $self->getParamValue("gmapDatabase");
  my $gsnapDirectory = $self->getParamValue("gsnapDirectory");
  my $quantify = $self->getParamValue("quantify");
  my $writeCovFiles = $self->getParamValue("writeCovFiles");
  my $clusterServer = $self->getSharedConfig('clusterServer');
  my $taskSize = $self->getConfig("taskSize");

  my $sraQueryString = $self->getParamValue("sraQueryString");

#  my $blatExec = $self->getConfig("$clusterServer.blatExec");
 # my $mdustExec = $self->getConfig("$clusterServer.mdustExec");

  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $useSpliceSiteDB = "false";
  my $iitDump = `iit_dump $workflowDataDir/$gsnapDirectory/$spliceSitesDatabase`;

  if($? == 0) {
    $useSpliceSiteDB = "true";
  }

  if($? == 127) {
    die "Command iit_dump not found";
  }



  if ($undo) {
    $self->runCmd(0, "rm -rf $workflowDataDir/$taskInputDir/");
  }else {
    $self->error("Declared input file '$workflowDataDir/$readFilePath' for param 'readFilePath' does not exist") if (!length($sraQueryString)>0 && !-e "$workflowDataDir/$readFilePath" && !-e "$workflowDataDir/$readFilePath.gz");
    #$self->testInputFile('readFilePath', "$workflowDataDir/$readFilePath") unless (length($sraQueryString)>0);
    # todo: test more inputs


      $self->runCmd(0,"mkdir -p $workflowDataDir/$taskInputDir");

      # make controller.prop file
      $self->makeDistribJobControllerPropFile($taskInputDir, 1, $taskSize,
				       "DJob::DistribJobTasks::GSNAPTask", $keepNode); 
      # make task.prop file
      my $taskPropFile = "$workflowDataDir/$taskInputDir/task.prop";
      open(F, ">$taskPropFile") || die "Can't open task prop file '$taskPropFile' for writing";

      my $taskPropFileContent="

genomeDatabase=$clusterWorkflowDataDir/$gsnapDirectory/$gmapDatabase
maskFile=$clusterWorkflowDataDir/$gsnapDirectory/$maskFile
iitFile=$clusterWorkflowDataDir/$gsnapDirectory/$spliceSitesDatabase
nPaths=$limitNU
quantify=$quantify
writeCovFiles=$writeCovFiles
isStrandSpecific=$strandSpecific
quantifyJunctions=$createJunctionsFile
topLevelGeneFootprintFile=$clusterWorkflowDataDir/$topLevelGeneFootprintFile
topLevelFastaFaiFile=$clusterWorkflowDataDir/$topLevelFastaFile.fai
hasKnownSpliceSites=$useSpliceSiteDB
";

    if(length($sraQueryString)>0){
      $taskPropFileContent .= "mateA=none\n";
      $taskPropFileContent .= "mateB=none\n";
      $taskPropFileContent .= "sraSampleIdQueryList=$sraQueryString\n";
      
    }else {
      $taskPropFileContent .= "mateA=$clusterWorkflowDataDir/$readFilePath\n";
      $taskPropFileContent .= "sraSampleIdQueryList=none\n";
      if($hasPairedEnds){
        $taskPropFileContent .= "mateB=$clusterWorkflowDataDir/$readFilePath.paired\n";
      }else {
        $taskPropFileContent .= "mateB=none\n";
      }
    }

      print F "$taskPropFileContent\n";
       close(F);
  }
}

1;


