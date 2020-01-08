package ApiCommonWorkflow::Main::WorkflowSteps::LoadEbiDumper;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $organismAbbrev = $self->getParamValue('organismAbbrev'); 
  my $databaseDir = $self->getParamValue('databaseDir');
  my $loaderDir =  $self->getParamValue("loaderDir"); 

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--logDir $workflowDataDir/$loaderDir --table_reader 'ApiCommonData::Load::EBITableReader' --databaseDir $workflowDataDir/$databaseDir --database $organismAbbrev --mode load";


  $self->testInputFile('inputFile', "$workflowDataDir/$databaseDir");

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertUniDB", $args);
}



1;
