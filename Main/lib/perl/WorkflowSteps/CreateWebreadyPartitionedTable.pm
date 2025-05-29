package ApiCommonWorkflow::Main::WorkflowSteps::CreateWebreadyPartitionedTable;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

# create a child partition table

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $psqlDirName = $self->getParamValue('psqlDirName');   # global orgSpecific or comparative
  my $mode = $self->getParamValue('mode');
  my $tableName = $self->getParamValue('tableName');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $projectId = $self->getParamValue('projectName');
  my $gusConfigFile = $self->getParamValue('gusConfigFile');

  $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";

  my $schema = $self->getSharedConfig('schema');

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $psqlDirPath = "$ENV{GUS_HOME}/lib/psql/webready/$psqlDirName";

  my $args;
  if ($mode eq 'child') {
    my $taxonId = $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getTaxonId();
    my $args = "--mode $mode --psqlDirPath $psqlDirPath --tableName $tableName --schema $schema --projectId $projectId --organismAbbrev $organismAbbrev --taxonId $taxonId";
  } else {
    my $args = "--mode $mode --psqlDirPath $psqlDirPath --tableName $tableName --schema $schema --projectId $projectId --taxonId 1";
  }
  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::CreateDenormalizedTable", $args);

}

1;

