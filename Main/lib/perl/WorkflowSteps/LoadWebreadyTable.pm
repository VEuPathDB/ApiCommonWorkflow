package ApiCommonWorkflow::Main::WorkflowSteps::LoadWebreadyTable;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

# this plugin is used for webready tables where we do not want the undo to drop the table
# an example is where the comparative graph loads into a pre-existing partitioned table created in the orgSpecific graph
# in this case, the undo in the comparative graph cannot drop the table
#
# this step runs a psql file on undo instead of dropping tables
# if the psql script for loading is called MyLoadScript.psql
# the script to run on undo should be in the same location and called Undo_MyLoadScript.psql

sub run {
  my ($self, $test, $undo) = @_;

  my $psqlDirName = $self->getParamValue('psqlDirName');
  my $tableName = $self->getParamValue('fileBasename');
  my $projectId = $self->getParamValue('projectName');
  my $gusConfigFile = $self->getParamValue('gusConfigFile');

  my $schema = $self->getSharedConfig('webreadySchema');

  $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $psqlDirPath = "$ENV{GUS_HOME}/lib/psql/webready/$psqlDirName";

  my $args = "--mode standard --psqlDirPath $psqlDirPath --tableName $tableName --schema $schema --projectId $projectId --taxonId 1";

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::LoadDenormalizedTable", $args);

}

1;

