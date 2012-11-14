package ApiCommonWorkflow::Main::WorkflowSteps::DatasetLoaderInsertExtDb;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $datasetName = $self->getParamValue('datasetName');
    my $datasetLoaderXmlFile = $self->getParamValue('datasetLoaderXmlFileName');
    my $dataDirPath = $self->getParamValue('dataDir');
    my $datasetLoader = $self->getDatasetLoader($datasetName, $datasetLoaderXmlFile, $dataDirPath);

    # if has a parent dataset loader, then assume the ext db has already been inserted
    # (this is validated in the DatasetLoaderInsertExtDbRls step)
    return if $datasetLoader->getParentDatasetLoader();

    my $dbPluginArgs = "--name '$datasetName' ";

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



