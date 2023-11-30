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


  
  if ($undo) {
    $self->runCmd(0, "ga ApiCommonData::Load::Plugin::InsertUniDB --database $organismAbbrev --table_reader 'ApiCommonData::Load::EBIReaderForUndo' --logDir $workflowDataDir/$loaderDir --mode undo --commit");

    $self->runCmd(0, "rm -rf $workflowDataDir/$loaderDir");
  } else {
    $self->runCmd($test, "mkdir -p $workflowDataDir/$loaderDir");
  }  
  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertUniDB", $args);
}


sub getMessageForError {
  my ($self, $undoPlugin) = @_;

  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $loaderDir =  $self->getParamValue("loaderDir");
  my $workflowDataDir = $self->getWorkflowDataDir();


  my $msgForError=
"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Since this plugin step FAILED, please CLEAN UP THE DATABASE by calling:

  ga ApiCommonData::Load::Plugin::InsertUniDB --database $organismAbbrev --table_reader 'ApiCommonData::Load::EBIReaderForUndo' --logDir $workflowDataDir/$loaderDir --mode undo --commit

And

 ga GUS::Community::Plugin::Undo --plugin ApiCommonData::Load::Plugin::InsertUniDB --workflowContext --algInvocationId 'XXXXXX' --commit

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
";



  return $msgForError;

}

1;
