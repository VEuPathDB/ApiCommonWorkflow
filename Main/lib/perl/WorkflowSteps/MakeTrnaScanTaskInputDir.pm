package ApiCommonWorkflow::Main::WorkflowSteps::MakeTrnaScanTaskInputDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameter values
  my $taskInputDir = $self->getParamValue("taskInputDir");
  my $genomicSeqsFile = $self->getParamValue("genomicSeqsFile");

  my $clusterServer = $self->getSharedConfig('clusterServer');
  my $taskSize = $self->getConfig("taskSize");
  my $tRNAscanDir = $self->getConfig("$clusterServer.tRNAscanDir");


  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
    $self->runCmd(0, "rm -rf $workflowDataDir/$taskInputDir/");
  }else {
    $self->testInputFile('genomicSeqsFile', "$workflowDataDir/$genomicSeqsFile");

      $self->runCmd(0,"mkdir -p $workflowDataDir/$taskInputDir");

      # make controller.prop file
      $self->makeDistribJobControllerPropFile($taskInputDir, 1, $taskSize,
				       "DJob::DistribJobTasks::tRNAscanTask"); 

      # make task.prop file
      my $taskPropFile = "$workflowDataDir/$taskInputDir/task.prop";
      open(F, ">$taskPropFile") || die "Can't open task prop file '$taskPropFile' for writing";

      print F
"tRNAscanDir=$tRNAscanDir
inputFilePath=$clusterWorkflowDataDir/$genomicSeqsFile
trainingOption=C
";
      close(F);
  }
}

1;
