package ApiCommonWorkflow::Main::WorkflowSteps::CopyDownloadFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $fromFile = $self->getParamValue('fromFile');
  my $toFile = $self->getParamValue('toFile');

  my $apiSiteFilesDir = $self->getSharedConfig('apiSiteFilesDir');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "cp $apiSiteFilesDir/$fromFile $workflowDataDir/$toFile";

  if ($test) {
    $self->testInputFile('fromFile', "$apiSiteFilesDir/$fromFile");
    $self->runCmd(0, "echo test > $workflowDataDir/$toFile");
  }

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$toFile");
  } else {
    $self->runCmd($test, $cmd);
  }

}

sub getParamsDeclaration {
  return (
          'fromFile',
          'toFile',
         );
}

sub getConfigDeclaration {
  return (
         # [name, default, description]
         # ['', '', ''],
         );
}


