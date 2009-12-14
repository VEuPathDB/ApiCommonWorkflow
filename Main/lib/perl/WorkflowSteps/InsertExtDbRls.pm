package ApiCommonWorkflow::Main::WorkflowSteps::InsertExtDbRls;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $dataSourceName = $self->getParamValue('dataSourceName');
    $dataSource = $self->getDataSource($dataSourceName);
    my $extDbName=  $dataSource->getName();
    my $extDbRlsVer=  $dataSource->getVersion();

    my $releasePluginArgs = "--databaseName '$extDbName' --databaseVersion '$extDbRlsVer'";

    $self->runPlugin($test, 0, "GUS::Supported::Plugin::InsertExternalDatabaseRls", $releasePluginArgs);
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



