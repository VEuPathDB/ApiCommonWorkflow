package ApiCommonWorkflow::Main::WorkflowSteps::MakeInterproTaskInputDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $taskInputDir = $self->getParamValue('taskInputDir');
  my $proteinsFile = $self->getParamValue('proteinsFile');

  # get global properties
  my $email = $self->getSharedConfig('email');

  # get properties
  my $taskSize = $self->getConfig('taskSize');
  my $applications = $self->getConfig('applications');

  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
    $self->runCmd(0,"rm -rf $workflowDataDir/$taskInputDir");
  }else {
      if ($test) {
	  $self->testInputFile('proteinsFile', "$workflowDataDir/$proteinsFile");
      }
      
      $self->runCmd(0,"mkdir -p $workflowDataDir/$taskInputDir");
      # make controller.prop file
      $self->makeClusterControllerPropFile($taskInputDir, 1, $taskSize,
				       "DJob::DistribJobTasks::IprscanTask");
      # make task.prop file
      my $taskPropFile = "$workflowDataDir/$taskInputDir/task.prop";
      open(F, ">$taskPropFile") || die "Can't open task prop file '$taskPropFile' for writing";
      print F
"seqfile=$clusterWorkflowDataDir/$proteinsFile
outputfile=iprscan_out.xml
seqtype=p
appl=$applications
email=$email
crc=false
";

       #&runCmd($test, "chmod -R g+w $workflowDataDir/similarity/$queryName-$subjectName");
  }
}

sub getParamsDeclaration {
  return (
          'taskInputDir',
          'proteinsFile',
         );
}

sub getConfigDeclaration {
  return (
         # [name, default, description]
         # ['', '', ''],
         );
}


