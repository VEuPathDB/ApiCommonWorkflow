package ApiCommonWorkflow::Main::WorkflowSteps::LoadAnticodons;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFileRelativeToManualDeliveryDir = $self->getParamValue('inputFileRelativeToManualDeliveryDir');
  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');

  my $manualDeliveryDir = $self->getSharedConfig('manualDeliveryDir');

  my ($extDbName,$extDbRlsVer) = $self->getExtDbInfo($test,$genomeExtDbRlsSpec);

  my $args = "--data_file $manualDeliveryDir/$inputFileRelativeToManualDeliveryDir --genomeDbName '$extDbName' --genomeDbVer '$extDbRlsVer'";


  $self->testInputFile('inputFile', "$manualDeliveryDir/$inputFileRelativeToManualDeliveryDir");


  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertAntiCodon", $args);

}

1;

