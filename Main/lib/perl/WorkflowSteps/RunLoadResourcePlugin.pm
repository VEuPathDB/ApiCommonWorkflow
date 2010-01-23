package ApiCommonWorkflow::Main::WorkflowSteps::RunLoadResourcePlugin;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $dataSourceName = $self->getParamValue('dataSourceName');
    $self->{dataSource} = $self->getDataSource($dataSourceName);
    my $idempotenceTable = $self->getParamValue('idempotenceTable');
    if (!$undo
	&& $idempotenceTable
	&& $dataSource->testIdempotenceTable($idempotenceTable)) {
	$self->log("Data for this data source found in table '$idempotenceTable'.  Data source already loaded.  Doing nothing");
	return;
    } 

    my $plugin=  $self->{dataSource}->getPlugin();
    my $pluginArgs=  $self->{dataSource}->getPluginArgs();

    _formatForCLI($pluginArgs);

    $self->runPlugin($test, $undo, $plugin, $pluginArgs);
}

sub _formatForCLI {
    $_[0] =~ s/\\$//gm;
    $_[0] =~ s/[\n\r]+/ /gm;
}

sub getParamsDeclaration {
    return (
            'dataSourceName'
           );
}

sub getConfigDeclaration {
    return (
           # [name, default, description]
           );
}



