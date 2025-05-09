package ApiCommonWorkflow::Main::WorkflowSteps::InsertSignalP;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');

  my ($extDbName,$extDbRlsVer) = $self->getExtDbInfo($test,$genomeExtDbRlsSpec);

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--gff_file $workflowDataDir/$inputFile --extDbName '$extDbName' --extDbRlsVer '$extDbRlsVer'";


    #$self->testInputFile('inputFile', "$workflowDataDir/$inputFile");


  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::LoadSignalP", $args);

}

1;
