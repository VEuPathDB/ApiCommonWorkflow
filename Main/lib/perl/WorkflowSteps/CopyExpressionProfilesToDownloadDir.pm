package ApiCommonWorkflow::Main::WorkflowSteps::CopyExpressionProfilesToDownloadDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $copyFromDir = $self->getParamValue('copyFromDir');
  my $copyToDir = $self->getParamValue('copyToDir');
  my $configFile = $self->getParamValue('configFile');


  my $workflowDataDir = $self->getWorkflowDataDir();

  $self->runCmd(0, "mkdir -p $copyToDir");

  my $cmd = "copyExpressionProfilesToDownloadDir --inputDir $workflowDataDir/$copyFromDir  --outputDir $copyToDir --configFile $workflowDataDir/$configFile";

  if ($test) {
    $self->testInputFile('copyFromDir', "$workflowDataDir/$copyFromDir");
  }

  if ($undo) {
    $self->runCmd(0, "rm -fr $copyToDir");
  } else {
    $self->runCmd($test, $cmd);
  }

}

sub getParamsDeclaration {
  return (
          'copyFromDir',
          'copyToDir',
          'configFile',
         );
}

sub getConfigDeclaration {
  return (
         # [name, default, description]
         # ['', '', ''],
         );
}


