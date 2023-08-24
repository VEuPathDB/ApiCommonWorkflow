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
  my $gusConfigFile = $self->getGusConfigFile();

  my $args = "--logDir $workflowDataDir/$loaderDir --table_reader 'ApiCommonData::Load::EBITableReader' --databaseDir $workflowDataDir/$databaseDir --database $organismAbbrev --mode load";


  
  if ($undo) {
    $self->runCmd(0, "ga ApiCommonData::Load::Plugin::InsertUniDBPostgres --gusConfigFile $gusConfigFile --database $organismAbbrev --table_reader 'ApiCommonData::Load::EBIReaderForUndo' --logDir $workflowDataDir/$loaderDir --mode undo --commit");
    $self->runCmd(0, "rm -rf $workflowDataDir/$loaderDir");
  } else {
    $self->runCmd($test, "mkdir -p $workflowDataDir/$loaderDir");
  }  
  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertUniDBPostgres", $args);
}


1;
