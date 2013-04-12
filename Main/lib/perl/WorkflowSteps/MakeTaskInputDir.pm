package ApiCommonWorkflow::Main::WorkflowSteps::MakeTaskInputDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

# SUPER CLASS FOR MAKING DJOB TASK DIRS

sub run {
  my ($self, $test, $undo) = @_;

  # get parameter values
  my $taskInputDir = $self->getParamValue("taskInputDir");

  my $clusterServer = $self->getSharedConfig('clusterServer');
  my $taskSize = $self->getConfig("taskSize");

  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
    $self->runCmd(0, "rm -rf $workflowDataDir/$taskInputDir/");
  } else {
      if ($test) {
	  $self->testMode($workflowDataDir);  # provided by subclass
      }

      $self->runCmd(0,"mkdir -p $workflowDataDir/$taskInputDir");

      # make controller.prop file
      $self->makeDistribJobControllerPropFile($taskInputDir, $cpus, $taskSize,
				       "DJob::DistribJobTasks::BlastSimilarityTask"); 

      my $taskPropFile = "$workflowDataDir/$taskInputDir/task.prop";
      open(F, ">$taskPropFile") || die "Can't open task prop file '$taskPropFile' for writing";

      print F  $self->getTaskPropFileContents("$clusterWorkflowDataDir");
      close(F);

      $self->doAdditionalStuff();
  }
}

# subclasses can override this to do their test mode checking.  only called if in test mode
sub testMode {
    my ($self, $workflowDataDir) = @_;
}

# subclasses must override this to provide the body of the task.prop file
sub getTaskPropFileContents {
    my ($self, $clusterWorkflowDataDir) = @_;
    die "subclass is not overriding this method";
}

# subclasses can override this to do any additional work, eg task-specific config files
sub doAdditionalStuff {
    my ($self) = @_;
}
