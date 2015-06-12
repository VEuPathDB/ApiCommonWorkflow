package ApiCommonWorkflow::Main::WorkflowSteps::LoadChEBI;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $gusInstance = $self->getGusInstanceName();
  my $chebiLogin = 'chebi';
  my $chebiPassword = $self->getConfig('chebiPassword');

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $dataDir = $workflowDataDir . "/" . $self->getParamValue('dataDir');

  my $cmd = "loadChEBI.bash -d $dataDir -i $gusInstance -u $chebiLogin -p $chebiPassword";

  if ($undo) {
     $self->runCmd(0, "echo exit|sqlplus $chebiLogin/$chebiPassword@$gusInstance @$dataDir/disable_constraints.sql");
     $self->runCmd(0, "sqlplus $chebiLogin/$chebiPassword@$gusInstance @$ENV{GUS_HOME}/lib/sql/apidbschema/dropChebiTables.sql");
  } else {
    $self->runCmd($test, cmd);
  }
}

1;
