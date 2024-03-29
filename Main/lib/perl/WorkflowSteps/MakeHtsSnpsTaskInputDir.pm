package ApiCommonWorkflow::Main::WorkflowSteps::MakeHtsSnpsTaskInputDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameter values
  my $taskInputDir = $self->getParamValue("taskInputDir");
  my $readsFile = $self->getParamValue("readsFile");
  my $pairedReadsFile = $self->getParamValue("pairedReadsFile");
  my $hasPairedReads = $self->getParamValue("hasPairedReads");
  my $genomicSeqsFile = $self->getParamValue("genomicSeqsFile");
  my $indexDir = $self->getParamValue("indexDir");
  my $strain = $self->getParamValue("strain");
  my $clusterServer = $self->getSharedConfig('clusterServer');
  my $snpPercentCutoff = $self->getParamValue("snpPercentCutoff");
  my $varscanBinPath = $self->getConfig("$clusterServer.varscanBinPathCluster");
  my $gatkBinPath = $self->getConfig("$clusterServer.gatkBinPathCluster");

  # expects string true/false
  my $isColorspace = $self->getParamValue("isColorspace");
 # my $hasPairedEnds =$self->getParamValue("hasPairedEnds");
  my $sraQueryString = $self->getParamValue("sraQueryString");

  my $taskSize = $self->getConfig("taskSize");
  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
    $self->runCmd(0, "rm -rf $workflowDataDir/$taskInputDir/");
  }else {


    if (!length($sraQueryString)>0 && !-e "$workflowDataDir/$readsFile") {
      $self->error("Declared input file '$workflowDataDir/$readsFile' for param 'readsFile' does not exist");
    }

    $self->testInputFile('genomicSeqsFile', "$workflowDataDir/$genomicSeqsFile");


      $self->runCmd(0,"mkdir -p $workflowDataDir/$taskInputDir");

      # make controller.prop file
      $self->makeDistribJobControllerPropFile($taskInputDir, 1, $taskSize,
				       "DJob::DistribJobTasks::HtsSnpTask", 0); 
      # make task.prop file
      my $taskPropFile = "$workflowDataDir/$taskInputDir/task.prop";
      open(F, ">$taskPropFile") || die "Can't open `task prop file '$taskPropFile' for writing";

      my $taskPropFileContent="
varscan=$varscanBinPath
gatk=$gatkBinPath
fastaFile=$clusterWorkflowDataDir/$genomicSeqsFile
bowtieIndex=$clusterWorkflowDataDir/$indexDir
strain=$strain
isColorspace=$isColorspace
hasPairedEnds=$hasPairedReads
";
      $taskPropFileContent .= "snpPercentCutoff=$snpPercentCutoff\n" if $snpPercentCutoff;

      if(length($sraQueryString)>0){
	  $taskPropFileContent .= "mateA=none\n";
	  $taskPropFileContent .= "mateB=none\n";
	  $taskPropFileContent .= "sraSampleIdQueryList=$sraQueryString\n";

      }else {
	  $taskPropFileContent .= "mateA=$clusterWorkflowDataDir/$readsFile\n";
	  $taskPropFileContent .= "sraSampleIdQueryList=none\n";
	  if($hasPairedReads eq "true"){
	      $taskPropFileContent .= "mateB=$clusterWorkflowDataDir/$pairedReadsFile\n";
	  }else {
	      $taskPropFileContent .= "mateB=none\n";
	  }
      }



      print F "$taskPropFileContent\n";
       close(F);
  }
}

1;
