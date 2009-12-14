package ApiCommonWorkflow::Main::WorkflowSteps::InsertExtDb;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $dataSourceName = $self->getParamValue('dataSourceName');
    my $dataSource = $self->getDataSource($dataSourceName);
    my $extDbName = $dataSource->getLegacyExtDbName();
    $extDbName || $extDbName = $dataSource->getName();

    my $dbPluginArgs = "--name '$extDbName' ";
    
    $self->runPlugin($test, $undo, "GUS::Supported::Plugin::InsertExternalDatabase", $dbPluginArgs);

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



