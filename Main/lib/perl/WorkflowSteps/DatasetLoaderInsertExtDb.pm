package ApiCommonWorkflow::Main::WorkflowSteps::ResourceInsertExtDb;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $dataSourceName = $self->getParamValue('datasetName');
    my $dataSourceXmlFile = $self->getParamValue('datasetLoaderXmlFileName');
    my $dataDirPath = $self->getParamValue('dataDir');
    my $dataSource = $self->getDataSource($dataSourceName, $dataSourceXmlFile, $dataDirPath);

    # if has a parent resource, then assume the ext db has already been inserted
    # (this is validated in the ResourceInsertExtDbRls step)
    return if $dataSource->getParentResource();

    my $dbPluginArgs = "--name '$dataSourceName' ";

    $self->runPlugin($test, $undo, "GUS::Supported::Plugin::InsertExternalDatabase", $dbPluginArgs);

}


sub getParamsDeclaration {
    return (
	'datasetName',
	'datasetLoaderXmlFileName',
        'dataDir'
	);
}

sub getConfigDeclaration {
    return (
           # [name, default, description]
           );
}



