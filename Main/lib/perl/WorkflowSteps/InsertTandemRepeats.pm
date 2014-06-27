package ApiCommonWorkflow::Main::WorkflowSteps::InsertTandemRepeats;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');

  my ($extDbName,$extDbRlsVer) = $self->getExtDbInfo($test,$genomeExtDbRlsSpec);

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--tandemRepeatFile $workflowDataDir/$inputFile --extDbName '$extDbName' --extDbVersion '$extDbRlsVer'";


  $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");

  $self->runPlugin($test, $undo, "GUS::Supported::Plugin::InsertTandemRepeatFeatures", $args);
}

1;

