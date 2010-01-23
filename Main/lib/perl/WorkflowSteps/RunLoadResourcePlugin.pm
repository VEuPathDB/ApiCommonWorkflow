package ApiCommonWorkflow::Main::WorkflowSteps::RunLoadResourcePlugin;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $dataSourceName = $self->getParamValue('dataSourceName');
    $dataSource = $self->getDataSource($dataSourceName);
    my $idempotenceTable = $self->getParamValue('idempotenceTable');
    if (!$undo && !$test
	&& $idempotenceTable
	&& $self->testIdempotenceTable($idempotenceTable, $dataSource)) {
	$self->log("Data for this data source found in table '$idempotenceTable'.  Data source already loaded.  Doing nothing");
	return;
    } 

    my $plugin =  $dataSourc->getPlugin();
    my $pluginArgs =  $dataSource->getPluginArgs();

    _formatForCLI($pluginArgs);

    $self->runPlugin($test, $undo, $plugin, $pluginArgs);
}

sub _formatForCLI {
    $_[0] =~ s/\\$//gm;
    $_[0] =~ s/[\n\r]+/ /gm;
}

sub testIdempotenceTable {
    my ($idempotenceTable, $dataSource) = @_;

    my $extDbName = $dataSource->getName();
    my $extDbRls = $dataSource->getVersion();
    my $extDbRlsId = $self->getExtDbRlsId(0, "$extDbName|$extDbRls");
    my $sql = "
select count(*) from $idempotenceTable
where external_database_release_id = $extDbRlsId";

    my $cmd = "getValueFromTable --idSQL \"$sql\"";

    my $count = $self->runCmd($test, $cmd);
    return $count;
}



sub getParamsDeclaration {
    return (
	'dataSourceName',
	'idempotenceTable'
	);
}

sub getConfigDeclaration {
    return (
           # [name, default, description]
           );
}



