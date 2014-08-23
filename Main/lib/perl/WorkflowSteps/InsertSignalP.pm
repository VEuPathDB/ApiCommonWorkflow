package ApiCommonWorkflow::Main::WorkflowSteps::InsertSignalP;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');

  my ($extDbName,$extDbRlsVer) = $self->getExtDbInfo($test,$genomeExtDbRlsSpec);

  my $version = $self->getConfig('version');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--data_file $workflowDataDir/$inputFile --algName 'SignalP' --algVer '$version' --algDesc 'SignalP' --extDbName '$extDbName' --extDbRlsVer '$extDbRlsVer' --useSourceId";


    $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");


  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::LoadSignalP", $args);

}

1;
