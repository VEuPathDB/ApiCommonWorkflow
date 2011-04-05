package ApiCommonWorkflow::Main::WorkflowSteps::MakePsipredTaskDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $taskInputDir = $self->getParamValue('taskInputDir');
  my $proteinsFile = $self->getParamValue('proteinsFile');
  my $nrdbFile = $self->getParamValue('nrdbFile');

  # get step properties
  my $taskSize = $self->getConfig('taskSize');
  my $psipredPath = $self->getConfig('clusterpath');
  my $ncbiBinPath = $self->getConfig('ncbiBinPath');

  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
    $self->runCmd(0,"rm -rf $workflowDataDir/$taskInputDir");
  }else {
      if ($test) {
	  $self->testInputFile('proteinsFile', "$workflowDataDir/$proteinsFile");
	  $self->testInputFile('nrdbFile', "$workflowDataDir/$nrdbFile");
      }
      
      $self->runCmd(0,"mkdir -p $workflowDataDir/$taskInputDir");

      # make controller.prop file
      $self->makeClusterControllerPropFile($taskInputDir, 2, $taskSize,
				       "DJob::DistribJobTasks::PsipredTask");

      # make task.prop file
      my $taskPropFile = "$workflowDataDir/$taskInputDir/task.prop";
      open(F, ">$taskPropFile") || die "Can't open task prop file '$taskPropFile' for writing";

      print F
"psipredDir=$psipredPath
dbFilePath=$clusterWorkflowDataDir/$nrdbFile
inputFilePath=$clusterWorkflowDataDir/$proteinsFile
ncbiBinDir=$ncbiBinPath
";
      close(F);
  }
}

sub getParamsDeclaration {
  return (
          'taskInputDir',
          'proteinsFile',
          'nrdbFile',
         );
}

sub getConfigDeclaration {
  return (
         # [name, default, description]
           ['ncbiBinPath', '', ''],
           ['psipredPath', '', ''],
           ['taskSize', '', ''],
         );
}

