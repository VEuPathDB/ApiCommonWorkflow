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
  my $hasPairedReads = $self->getBooleanParamValue("hasPairedReads");
  my $genomicSeqsFile = $self->getParamValue("genomicSeqsFile");
  my $indexDir = $self->getParamValue("indexDir");
  my $strain = $self->getParamValue("strain");

  # expects string true/false
  my $isColorspace = $self->getParamValue("isColorspace");

  my $sraQueryString = $self->getParamValue("sraQueryString");

  my $taskSize = $self->getConfig("taskSize");
  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
    $self->runCmd(0, "rm -rf $workflowDataDir/$taskInputDir/");
  }else {
      if ($test) {
	  $self->testInputFile('readsFile', "$workflowDataDir/$readsFile");
	  $self->testInputFile('genomicSeqsFile', "$workflowDataDir/$genomicSeqsFile");
      }

      $self->runCmd(0,"mkdir -p $workflowDataDir/$taskInputDir");

      # make controller.prop file
      $self->makeDistribJobControllerPropFile($taskInputDir, 1, $taskSize,
				       "DJob::DistribJobTasks::HtsSnpTask", 0); 
      # make task.prop file
      my $taskPropFile = "$workflowDataDir/$taskInputDir/task.prop";
      open(F, ">$taskPropFile") || die "Can't open `task prop file '$taskPropFile' for writing";

      my $taskPropFileContent="
fastaFile=$clusterWorkflowDataDir/$genomicSeqsFile
bowtieIndex=$clusterWorkflowDataDir/$indexDir
strain=$strain
isColorspace=$isColorspace
sraSampleIdQueryList=$sraQueryString
";
      if(length($sraQueryString)>0){
	  $taskPropFileContent .= "mateA=none\n";
	  $taskPropFileContent .= "mateB=none\n";
      }else {
	  $taskPropFileContent .= "mateA=$clusterWorkflowDataDir/$readsFile\n";
	  if($hasPairedReads){
	      $taskPropFileContent .= "mateB=$clusterWorkflowDataDir/$pairedReadsFile\n";
	  }else {
	      $taskPropFileContent .= "mateB=none\n";
	  }
      }



      print F "$taskPropFileContent\n";
       close(F);
  }
}

sub getParamsDeclaration {
  return ('taskInputDir',
	  'readsFile',
	  'hasPairedReads',
	  'genomicSeqsFile',
	  'indexDir',
	  'strain',
          'isColorspace',
          'sraQueryString',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	  ['taskSize', "", ""],
	 );
}

