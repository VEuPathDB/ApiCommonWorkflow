package ApiCommonWorkflow::Main::WorkflowSteps::InsertDBxRefs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $extDbName = $self->getParamValue('extDbName');
  my $extDbVersion = $self->getParamValue('extDbVersion');
  my $tableName = $self->getParamValue('tableName');
  my $viewName = $self->getParamValue('viewName');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');

  my $workflowDataDir = $self->getWorkflowDataDir();

  $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");

  my $args = "--DbRefMappingFile $workflowDataDir/$inputFile"
    . " --extDbName '$extDbName'"
    . " --extDbReleaseNumber '$extDbVersion'"
    . " --columnSpec 'primary_identifier,secondary_identifier'"
    . " --tableName '$tableName'"
    . " --viewName '$viewName'"
    . " --geneExternalDatabaseSpec '$genomeExtDbRlsSpec'"
    . " --organismAbbrev '$organismAbbrev'";

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertDBxRefs", $args);
}

1;
