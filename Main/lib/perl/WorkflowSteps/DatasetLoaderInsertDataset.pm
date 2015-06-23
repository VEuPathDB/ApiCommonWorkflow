package ApiCommonWorkflow::Main::WorkflowSteps::DatasetLoaderInsertDataset;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $datasetName = $self->getParamValue('datasetName');
    my $datasetLoaderXmlFile = $self->getParamValue('datasetLoaderXmlFileName');
    my $dataDirPath = $self->getParamValue('dataDir');

    my $datasetLoader = $self->getDatasetLoader($datasetName, $datasetLoaderXmlFile, $dataDirPath);

    my $extDbName = $datasetLoader->getParentDatasetLoader()?
	$datasetLoader->getParentDatasetLoader()->getName() : $datasetName;

    my $version = $datasetLoader->getVersion();
    my $organismAbbrev = $datasetLoader->getOrganismAbbrev();
    my $scope = $datasetLoader->getScope();
    my $type = $datasetLoader->getType();
    my $subType = $datasetLoader->getSubType();

    my $isSpeciesScope = $scope eq 'species'? "--isSpeciesScope" : "";
    my $tp = $type? "--type $type" : "";
    my $stp = $subType? "--subType $subType" : "";

    my $taxonId;
    if ($organismAbbrev) {
	my $t = $self->getOrganismInfo($test, $organismAbbrev)->getTaxonId();
	$taxonId = "--taxonId $t";
	die "Can't find taxon_id for organismAbbrev '$organismAbbrev'\n" unless $t;
    }

    my $dbPluginArgs = "--dataSourceName '$datasetName' --version '$version' --externalDatabaseName '$extDbName' $isSpeciesScope $taxonId $tp $stp";

    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertDataSource", $dbPluginArgs);

}

1;

