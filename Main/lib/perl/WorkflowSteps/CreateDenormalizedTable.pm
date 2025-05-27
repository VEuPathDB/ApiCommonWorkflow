package ApiCommonWorkflow::Main::WorkflowSteps::CreateDenormalizedTable;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $psqlDirName = $self->getParamValue('psqlDirName');   # global orgSpecific or comparative
  my $mode = $self->getParamValue('mode');   # parent, child or dontcare
  my $tableName = $self->getParamValue('tableName');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $projectId = $self->getParamValue('projectName');
  my $schema = $self->getParamValue('schema');
  my $gusConfigFile = $self->getParamValue('gusConfigFile');

  $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $psqlDirPath = "$ENV{GUS_HOME}/lib/psql/webready/$psqlDirName";

  my $args;
  if ($mode eq 'child') {
    my $taxonId = $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getTaxonId();
    $args = "--mode $mode --psqlDirPath $psqlDirPath --tableName $tableName --schema $schema --projectId $projectId --organismAbbrev $organismAbbrev --taxonId $taxonId";
  } else {
    $args = "--mode $mode --psqlDirPath $psqlDirPath --tableName $tableName --schema $schema --projectId $projectId --taxonId 1";
  }

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::CreateDenormalizedTable", $args);

}

1;

