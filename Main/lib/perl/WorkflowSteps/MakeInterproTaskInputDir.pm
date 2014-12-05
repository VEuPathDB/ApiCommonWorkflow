package ApiCommonWorkflow::Main::WorkflowSteps::MakeInterproTaskInputDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $taskInputDir = $self->getParamValue('taskInputDir');
  my $proteinsFile = $self->getParamValue('proteinsFile');

  # get properties
  my $clusterServer = $self->getSharedConfig('clusterServer');
  my $taskSize = $self->getConfig("taskSize");
  my $applications = $self->getConfig("applications");

  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
    $self->runCmd(0,"rm -rf $workflowDataDir/$taskInputDir");
  }else {
    $self->testInputFile('proteinsFile', "$workflowDataDir/$proteinsFile");
      
      $self->runCmd(0,"mkdir -p $workflowDataDir/$taskInputDir");
      # make controller.prop file
      $self->makeDistribJobControllerPropFile($taskInputDir, 1, $taskSize,
				       "DJob::DistribJobTasks::Iprscan5Task");
      # make task.prop file
      my $taskPropFile = "$workflowDataDir/$taskInputDir/task.prop";
      open(F, ">$taskPropFile") || die "Can't open task prop file '$taskPropFile' for writing";
      print F
"seqfile=$clusterWorkflowDataDir/${proteinsFile}.NoAsterisks
outputfile=iprscan_out.tsv
seqtype=p
appl=$applications
email=dontcare\@dontcare.com
";

       #&runCmd($test, "chmod -R g+w $workflowDataDir/similarity/$queryName-$subjectName");
  }
}

1;
