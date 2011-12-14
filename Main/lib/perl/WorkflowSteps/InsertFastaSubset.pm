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

my $args = "--externalDatabaseName $extDbName --externalDatabaseVersion $extDbRlsVer --sequenceFile $workflowDataDir/$fastaFile --sourceIdsFile  $workflowDataDir/$idsFile --regexSecondaryId '>gi\\|\\d+\\|\\w+\\|(\\w+\\.?\\w+)\\|' --regexDesc '^>gi\\|\\d+\\|\\w+\\|\\w+\\.?\\w+\\|(\.+)' --regexSourceId '>gi\\|(\\d+)\\|' --tableName DoTS::ExternalAASequence";

  if ($test) {
    $self->testInputFile('fastaFile', "$workflowDataDir/$fastaFile");
    $self->testInputFile('idsFile', "$workflowDataDir/$idsFile");
  }

  $self->runPlugin($test,$undo, "GUS::Supported::Plugin::LoadFastaSequences",$args);

}


sub getConfigDeclaration {
  return ();
}


