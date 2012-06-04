package ApiCommonWorkflow::Main::WorkflowSteps::LoadFastaSequences;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $extDbRlsSpec = $self->getParam('extDbRlsSpec'); 
  my $ncbiTaxId = $self->getParam('ncbiTaxId')  
  my $sequenceFile = $self->getParam('sequenceFile')  
  my $soTermName = $self->getParam('soTermName');
  my $regexSourceId = $self->getParam('regexSourceId');
  my $tableName = $self->getParam('tableName');

  my ($extDbName,$extDbRlsVer) = $self->getExtDbInfo($test, $extDbRlsSpec);
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--externalDatabaseName $extDbName --externalDatabaseVersion $extDbRlsVer --sequenceFile $workflowDataDir/$sequenceFile --regexSourceId $soTermName --tableName \"$tableName\" ";

  $args .= "--soTermName $soTermName " if defined $soTermName;
  $args .= "--ncbiTaxId $ncbiTaxId " if defined $ncbiTaxId;

  if ($test) {
    $self->testInputFile('inputFile', "$workflowDataDir/$sequenceFile");
  }

  $self->runPlugin($test, $undo, "GUS::Supported::Plugin::LoadFastaSequences", $args);
}

sub getConfigDeclaration {
  return (
      # [name, default, description]
     );
}

sub getParamDeclaration {
  return ('extDbRlsSpec',
          'ncbiTaxId',
          'sequenceFile',
          'soTermName',
          'regexSourceId',
          'tableName'
     );
}


1;