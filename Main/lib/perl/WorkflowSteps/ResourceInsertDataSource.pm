package ApiCommonWorkflow::Main::WorkflowSteps::ResourceInsertDataSource;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $dataSourceName = $self->getParamValue('resourceName');
    my $dataSourceXmlFile = $self->getParamValue('resourceXmlFileName');
    my $dataDirPath = $self->getParamValue('dataDir');
    my $dataSource = $self->getDataSource($dataSourceName, $dataSourceXmlFile, $dataDirPath);
    
    my $version = $dataSource->getVersion();
    my $organismAbbrev = $dataSource->getOrganismAbbrev();
    my $scope = $dataSource->getScope();

    my $isSpeciesScope = $scope eq 'species'? "--isSpeciesScope" : "";
    my $taxonId;
    if ($organismAbbrev) {
	my $t = $self->getOrganismInfo($organismAbbrev)->getTaxonId();
	$taxonId = "--taxonId $t";
    }

    my $dbPluginArgs = "--name '$dataSourceName' --version '$version' $isSpeciesScope $taxonId";

    $self->runPlugin($test, $undo, "ApiCommonData::Load::InsertDataSource", $dbPluginArgs);

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



