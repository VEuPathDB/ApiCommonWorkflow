package ApiCommonWorkflow::Main::WorkflowSteps::RunPlugin;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $dataSourceName = $self->getParamValue('dataSourceName');
    my $dataSource = $self->getDataSource($dataSourceName);
    my $plugin=  $dataSource->getPlugin();
    my $pluginArgs=  $dataSource->getPluginArgs();

    $self->runPlugin($test, $undo, $plugin, $pluginArgs);
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



