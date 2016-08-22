package ApiCommonWorkflow::Main::WorkflowSteps::InsertIntronJunction;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $rnaSeqExtDbRlsSpec = $self->getParamValue('rnaSeqExtDbRlsSpec');
  my $sampleName = $self->getParamValue('sampleName');

  my ($extDbName,$extDbRlsVer) = $self->getExtDbInfo($test,$rnaSeqExtDbRlsSpec);

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--inputFile $workflowDataDir/$inputFile --extDbName $extDbName --extDbVer $extDbRlsVer --sampleName $sampleName";


  #$self->testInputFile('inputFile', "$workflowDataDir/$inputFile");


  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertIntronJunction", $args);
}


1;


