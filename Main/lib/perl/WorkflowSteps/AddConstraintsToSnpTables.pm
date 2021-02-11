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

  my $sql=<<SQL;
    select drops from (
	select 'WHENEVER SQLERROR EXIT SQL.SQLCODE;' as drops, 1 as num from dual
	union
	select 'alter table ' || owner || '.' || table_name || ' drop constraint ' || constraint_name || ';' as drops,
	       DECODE(constraint_type,'R',2,'U',3,'P',4) as num
	from all_constraints
	where owner = 'APIDB' and table_name in ('SNP','SEQUENCEVARIATION') and constraint_type in ('R','U','P') 
	union
	select 'drop index APIDB.' || index_name || ';' as drops, 5 as num
	from all_indexes
	where owner = 'APIDB' and table_name in ('SNP','SEQUENCEVARIATION')
	      and index_name not in (select constraint_name from all_constraints where owner = 'APIDB' 
				     and table_name in ('SNP','SEQUENCEVARIATION') and constraint_type in ('R','U','P'))
	union
	select 'exit;' as drops, 6 as num from dual
    )
    order by num
SQL

  $self->runCmd($test, "mkdir $workflowDataDir/$dataDir") unless (-d "$workflowDataDir/$dataDir");
  my $sql_cmd="makeFileWithSql --sql \"$sql\" --outFile $workflowDataDir/$dataDir/dropConstraintsAndIndexesFromSnpTables.sql";
  $self->runCmd($test, $sql_cmd);
  unless($test){
		open(F, ">>$workflowDataDir/$dataDir/dropConstraintsAndIndexesFromSnpTables.sql") || die "Can't open task prop file '$workflowDataDir/$dataDir/dropConstraintsAndIndexesFromSnpTables.sql' for writing";
  		print F "exit;";
  		close(F);
  }
  my $drop_cmd = "sqlplus $gusLogin/$gusPassword\@$gusInstance \@$workflowDataDir/$dataDir/dropConstraintsAndIndexesFromSnpTables.sql ";
  my $add_cmd = "sqlplus $gusLogin/$gusPassword\@$gusInstance \@$ENV{GUS_HOME}/lib/sql/apidbschema/addConstraintsAndIndexesToSnpTables.sql ";

  if ($undo) {
     $self->runCmd(0, "rm -f $workflowDataDir/$dataDir/dropConstraintsToSnpTables.sql");
  } else {
      $self->runCmd(0, $drop_cmd);
      $self->runCmd(0, $add_cmd);
  }
}

1;
