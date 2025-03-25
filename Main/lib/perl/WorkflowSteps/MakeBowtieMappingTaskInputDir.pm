package ApiCommonWorkflow::Main::WorkflowSteps::MakeBowtieMappingTaskInputDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameter values
  my $taskInputDir = $self->getParamValue("taskInputDir");
  my $readsFile = $self->getParamValue("readsFile");
  my $pairedReadsFile = $self->getParamValue("pairedReadsFile");
  #my $hasPairedReads = $self->getBooleanParamValue("hasPairedReads");
  my $hasPairedReads = $self->getParamValue("hasPairedReads");
  #my $genomicSeqsFile = $self->getParamValue("genomicSeqsFile");
  my $indexDir = $self->getParamValue("indexDir");
  my $sampleName = $self->getParamValue("sampleName");
  my $sraQueryString = $self->getParamValue("sraQueryString");

  #my $clusterServer = $self->getSharedConfig('clusterServer');
  my $extraBowtieParams = $self->getParamValue("extraBowtieParams");
  $extraBowtieParams = 'none' unless($extraBowtieParams);

  my $seqSizeFile = $self->getParamValue("seqSizeFile");

  # expects string true/false 
  my $isColorspace = $self->getParamValue("isColorspace");
  my $removePCRDuplicates = $self->getParamValue("removePCRDuplicates");
  my $writeBedFile = $self->getParamValue("writeBedFile");

  my $taskSize = $self->getConfig("taskSize");
  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
    $self->runCmd(0, "rm -rf $workflowDataDir/$taskInputDir/");
  }else {

    $self->testInputFile('readsFile', "$workflowDataDir/$readsFile");

      $self->runCmd(0,"mkdir -p $workflowDataDir/$taskInputDir");

      # make controller.prop file
      $self->makeDistribJobControllerPropFile($taskInputDir, 1, $taskSize,
				       "DJob::DistribJobTasks::BowtieMappingTask", 0); 
      # make task.prop file
      my $taskPropFile = "$workflowDataDir/$taskInputDir/task.prop";
      open(F, ">$taskPropFile") || die "Can't open `task prop file '$taskPropFile' for writing";

      my $taskPropFileContent="
bowtieIndex=$clusterWorkflowDataDir/$indexDir
sampleName=$sampleName
isColorspace=$isColorspace
removePCRDuplicates=$removePCRDuplicates
writeBedFile=$writeBedFile
seqSizeFile=$clusterWorkflowDataDir/$seqSizeFile
extraBowtieParams=$extraBowtieParams
hasPairedEnds=$hasPairedReads
";

    if (!length($sraQueryString)>0 && !-e "$workflowDataDir/$readsFile") {
      $self->error("Declared input file '$workflowDataDir/$readsFile' for param 'readsFile' does not exist");
    }   

    if(length($sraQueryString)>0){
	    $taskPropFileContent .= "mateA=none\n";
	    $taskPropFileContent .= "mateB=none\n";
	    $taskPropFileContent .= "sraSampleIdQueryList=$sraQueryString\n";

    }else {
	    $taskPropFileContent .= "mateA=$clusterWorkflowDataDir/$readsFile\n";
	    $taskPropFileContent .= "sraSampleIdQueryList=none\n";
	    if($hasPairedReads eq 'true' && length($pairedReadsFile)>0){
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
