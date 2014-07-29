package ApiCommonWorkflow::Main::WorkflowSteps::MakeMassSpecTaskInputDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameter values
  my $taskInputDir = $self->getParamValue("taskInputDir");
  my $mgfFile = $self->getParamValue("mgfFile");

  # expects string true/false
  my $taskSize = $self->getConfig("taskSize");
  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
    $self->runCmd(0, "rm -rf $workflowDataDir/$taskInputDir/");
  }else {

    $self->testInputFile('mgfFile', "$workflowDataDir/$mgfFile");
	  
      $self->runCmd(0,"mkdir -p $workflowDataDir/$taskInputDir");

      # make controller.prop file
      $self->makeDistribJobControllerPropFile($taskInputDir, 1, $taskSize,
				       "DJob::DistribJobTasks::ProteomicsPipelineTask", 0); 
      # make task.prop file
      my $taskPropFile = "$workflowDataDir/$taskInputDir/task.prop";
      open(F, ">$taskPropFile") || die "Can't open `task prop file '$taskPropFile' for writing";

      my $taskPropFileContent="
mgfFile=$clusterWorkflowDataDir/$mgfFile
";
 
      print F "$taskPropFileContent\n";
       close(F);
  }
}

1;
