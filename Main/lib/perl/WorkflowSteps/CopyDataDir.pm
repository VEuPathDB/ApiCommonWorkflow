package ApiCommonWorkflow::Main::WorkflowSteps::CopyDataDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test,$undo) = @_;

  # get parameters
  my $fromDir = $self->getParamValue('fromDir');
  my $toDir = $self->getParamValue('toDir');

  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
      $self->runCmd(0, "rm -rf $workflowDataDir/$toDir");
  } else {  
    if(!$test){
    	$self->runCmd(0, "cp -r $workflowDataDir/$fromDir $workflowDataDir/$toDir");
    }
  }
}

1;


