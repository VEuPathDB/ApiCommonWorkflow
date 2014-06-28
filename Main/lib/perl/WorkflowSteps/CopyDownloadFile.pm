package ApiCommonWorkflow::Main::WorkflowSteps::CopyDownloadFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $fromFile = $self->getParamValue('fromFile');
  my $toFile = $self->getParamValue('toFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "cp $fromFile $workflowDataDir/$toFile";

  $self->testInputFile('fromFile', "$fromFile");
  if ($test) {
    $self->runCmd(0, "echo test > $workflowDataDir/$toFile");
  }

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$toFile");
  } else {
    $self->runCmd($test, $cmd);
  }

}

1;
