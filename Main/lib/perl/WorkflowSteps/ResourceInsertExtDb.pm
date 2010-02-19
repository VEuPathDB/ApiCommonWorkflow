package ApiCommonWorkflow::Main::WorkflowSteps::ResourceInsertExtDb;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $dataSourceName = $self->getParamValue('resourceName');
    my $dataSourceXmlFile = $self->getParamValue('resourceXmlFileName');
    my $dataDirPath = $self->getParamValue('dataDir');
    my $dataSource = $self->getDataSource($dataSourceName, $dataSourceXmlFile, $dataDirPath);

    my $extDbName = $dataSource->getLegacyExtDbName();
    $extDbName = $dataSource->getName() unless $extDbName;

    my $dbPluginArgs = "--name '$extDbName' ";

    $self->runPlugin($test, $undo, "GUS::Supported::Plugin::InsertExternalDatabase", $dbPluginArgs);

}


sub getParamsDeclaration {
    return (
	'resourceName',
	'resourceXmlFileName',
        'dataDir'
	);
}

sub getConfigDeclaration {
    return (
           # [name, default, description]
           );
}



