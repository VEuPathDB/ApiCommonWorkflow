package ApiCommonWorkflow::Main::WorkflowSteps::SymLinkDataDirFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test,$undo) = @_;

  # get parameters
  my $fromFile = $self->getParamValue('fromFile');
  my $toFile = $self->getParamValue('toFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$toFile");
  } else {
    #$self->testInputFile('fromFile', "$workflowDataDir/$fromFile");

    if(-e "$workflowDataDir/$fromFile") {
      $self->runCmd(0, "ln -s $workflowDataDir/$fromFile $workflowDataDir/$toFile");
    }
    else {
      $self->error("Could not create a sym link.  File $workflowDataDir/$fromFile does not exist");
    }

  }
}


1;

