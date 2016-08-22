package ApiCommonWorkflow::Main::WorkflowSteps::LoadFastaSequences;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec'); 
  my $ncbiTaxId = $self->getParamValue('ncbiTaxId'); 
  my $sequenceFile = $self->getParamValue('sequenceFile');  
  my $soTermName = $self->getParamValue('soTermName');
  my $regexSourceId = $self->getParamValue('regexSourceId');
  my $tableName = $self->getParamValue('tableName');

  my ($extDbName,$extDbRlsVer) = $self->getExtDbInfo($test, $extDbRlsSpec);
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--externalDatabaseName $extDbName --externalDatabaseVersion $extDbRlsVer --sequenceFile $workflowDataDir/$sequenceFile --regexSourceId '$regexSourceId' --tableName \"$tableName\" ";

  if ($soTermName) {
    my $soExtDbName = $self->getSharedConfig("sequenceOntologyExtDbName");

    $args .= "--soTermName $soTermName " ;
    $args .= "--SOExtDbRlsSpec '$soExtDbName|%' ";
  }

  $args .= "--ncbiTaxId $ncbiTaxId " if ($ncbiTaxId);


  $self->testInputFile('inputFile', "$workflowDataDir/$sequenceFile");

  $self->runPlugin($test, $undo, "GUS::Supported::Plugin::LoadFastaSequences", $args);
}



1;
