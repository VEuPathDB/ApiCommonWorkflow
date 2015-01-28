package ApiCommonWorkflow::Main::WorkflowSteps::AddConstraintsToSnpTables;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $gusInstance = $self->getGusInstanceName();
  my $gusLogin = $self->getGusDatabaseLogin();
  my $gusPassword = $self->getGusDatabasePassword();
  my $workflowDataDir = $self->getWorkflowDataDir();
  my $dataDir = $self->getParamValue('dataDir');
  my $cmd = "sqlplus $gusLogin/$gusPassword\@$gusInstance \@$ENV{GUS_HOME}/lib/sql/apidbschema/addConstraintsAndIndexesToSnpTables.sql ";

  if ($undo) {
      my $sql="select 'alter table ' || owner || '.' || table_name || ' drop constraint ' || constraint_name || ';' as drops from all_constraints where owner = 'APIDB' and table_name in ('SNP','SEQUENCEVARIATION') and constraint_type in ('R','U','P')  order by table_name";
      my $sql_cmd="makeFileWithSql --sql \"$sql\" --outFile $workflowDataDir/$dataDir/dropConstraintsToSnpTables.sql";
      $self->runCmd($test, $sql_cmd);
       my $undo_cmd = "sqlplus $gusLogin/$gusPassword\@$gusInstance $workflowDataDir/$dataDir/dropConstraintsToSnpTables.sql ";
  } else {
      $self->runCmd($test, $cmd);
  }
}

1;
