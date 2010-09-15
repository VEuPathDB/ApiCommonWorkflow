package ApiCommonWorkflow::Main::WorkflowSteps::InsertFastaSubset;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');
  my $fastaFile = $self->getParamValue('fastaFile');
  my $idsFile = $self->getParamValue('idsFile');

  my ($extDbName,$extDbRlsVer) = $self->getExtDbInfo($test,$extDbRlsSpec);

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--externalDatabaseName $extDbName --externalDatabaseVersion $extDbRlsVer --sequenceFile $workflowDataDir/$fastaFile --sourceIdsFile  $workflowDataDir/$idsFile --regexSourceId  '>gi\\|\\d+\\|\\w+\\|(\\w+\\.?\\w+)\\|' --regexDesc '^>gi\\|\\d+\\|\\w+\\|\\w+\\.?\\w+\\|(\.+)' --regexSecondaryId '>gi\\|(\\d+)\\|' --tableName DoTS::ExternalAASequence";

  if ($test) {
    $self->testInputFile('fastaFile', "$workflowDataDir/$fastaFile");
    $self->testInputFile('idsFile', "$workflowDataDir/$idsFile");
  }

  $self->runPlugin($test,$undo, "GUS::Supported::Plugin::LoadFastaSequences",$args);

}

sub getParamDeclaration {
  return (
	  'idsFile',
	  'extDbRlsSpec',
	  'fastaFile',
	 );
}


sub getConfigDeclaration {
  return ();
}


