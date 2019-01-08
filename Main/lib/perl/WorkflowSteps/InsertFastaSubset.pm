package ApiCommonWorkflow::Main::WorkflowSteps::InsertFastaSubset;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $extDbName = $self->getParamValue('extDbName');
  my $fastaFile = $self->getParamValue('fastaFile');
  my $idsFile = $self->getParamValue('idsFile');

  my $extDbVer = $self->getExtDbVersion($test, $extDbName);


  my $workflowDataDir = $self->getWorkflowDataDir();

 # my $args = "--externalDatabaseName $extDbName --externalDatabaseVersion $extDbRlsVer --sequenceFile $workflowDataDir/$fastaFile --sourceIdsFile  $workflowDataDir/$idsFile --regexSourceId  '>gi\\|\\d+\\|\\w+\\|(\\w+\\.?\\w+)\\|' --regexDesc '^>gi\\|\\d+\\|\\w+\\|\\w+\\.?\\w+\\|(\.+)' --regexSecondaryId '>gi\\|(\\d+)\\|' --tableName DoTS::ExternalAASequence";

my $args = "--externalDatabaseName $extDbName --externalDatabaseVersion $extDbVer --sequenceFile $workflowDataDir/$fastaFile --sourceIdsFile  $workflowDataDir/$idsFile --regexSecondaryId '^>(\\S+)' --regexDesc '^>\\S+ (.+?])' --regexSourceId '^>(\\S+)' --tableName DoTS::ExternalAASequence";


  $self->testInputFile('fastaFile', "$workflowDataDir/$fastaFile");
  $self->testInputFile('idsFile', "$workflowDataDir/$idsFile");

  unless($undo){
  	$self->runPlugin($test,0, "GUS::Supported::Plugin::LoadFastaSequences",$args);
  }else{
	$self->runPlugin($test,1, "ApiCommonData::Load::Plugin::LoadNothing",$args);
  }	
}


1;


