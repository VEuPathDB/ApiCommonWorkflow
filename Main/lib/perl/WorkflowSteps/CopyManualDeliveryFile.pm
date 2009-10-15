package ApiCommonWorkflow::Main::WorkflowSteps::CopyManualDeliveryFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $fromFile = $self->getParamValue('fromFile');
  my $toFile = $self->getParamValue('toFile');

  my $manualDeliveryDir = $self->getGlobalConfig('manualDeliveryDir');

  my $localDataDir = $self->getLocalDataDir();

  my $cmd = "cp $manualDeliveryDir/$fromFile $localDataDir/$toFile";

  if ($test) {
    $self->testInputFile('fromFile', "$manualDeliveryDir/$fromFile");
    $self->runCmd(0, "echo test > $localDataDir/$toFile");
  }

  if ($undo) {
    $self->runCmd(0, "rm -f $localDataDir/$toFile");
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


