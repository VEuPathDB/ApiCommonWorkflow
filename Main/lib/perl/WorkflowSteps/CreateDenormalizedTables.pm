package ApiCommonWorkflow::Main::WorkflowSteps::CreateDenormalizedTables;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $mode = $self->getParamValue('mode');   # parent, child or dontcare
  my $psqlDirPath = $self->getParamValue('psqlDirPath');
  my $tableName = $self->getParamValue('tableName');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $projectId = $self->getParamValue('projectName');
  my $schema = $self->getParamValue('schema');
  my $gusConfigFile = $self->getParamValue('gusConfigFile');

  $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";
  my $taxonId = $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getTaxonId();

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--mode $mode --psqlDirPath $psqlDirPath --tableName $tableName --schema $schema --projectId $projectId --organismAbbrev $organismAbbrev --taxonId 123456";

  $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::CreateDenormalizedTables", $args);

}

1;

