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
  my $sql="select 'alter table ' || owner || '.' || table_name || ' drop constraint ' || constraint_name || ';' as drops from all_constraints where owner = 'APIDB' and table_name in ('SNP','SEQUENCEVARIATION') and constraint_type in ('R','U','P')  order by table_name";
  my $sql_cmd="makeFileWithSql --sql \"$sql\" --outFile $workflowDataDir/$dataDir/dropConstraintsToSnpTables.sql";
  $self->runCmd($test, $sql_cmd);
  my $drop_cmd = "sqlplus $gusLogin/$gusPassword\@$gusInstance $workflowDataDir/$dataDir/dropConstraintsToSnpTables.sql ";
  my $add_cmd = "sqlplus $gusLogin/$gusPassword\@$gusInstance \@$ENV{GUS_HOME}/lib/sql/apidbschema/addConstraintsAndIndexesToSnpTables.sql ";

  if ($undo) {
     $self->runCmd(0, "rm -f $workflowDataDir/$dataDir/dropConstraintsToSnpTables.sql");
  } else {
      $self->runCmd(0, $drop_cmd);
      $self->runCmd(0, $add_cmd);
  }
}

1;
