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

    my $extDbName = $dataSource->getParentResource()? $dataSource->getParentResource() : $dataSourceName;

    my $version = $dataSource->getVersion();
    my $organismAbbrev = $dataSource->getOrganismAbbrev();
    my $scope = $dataSource->getScope();
    my $type = $dataSource->getType();
    my $subType = $dataSource->getSubType();

    my $isSpeciesScope = $scope eq 'species'? "--isSpeciesScope" : "";
    my $tp = $type? "--type $type" : "";
    my $stp = $subType? "--subType $subType" : "";

    my $taxonId;
    if ($organismAbbrev) {
	my $t = $self->getOrganismInfo($test, $organismAbbrev)->getTaxonId();
	$taxonId = "--taxonId $t";
    }

    my $dbPluginArgs = "--dataSourceName '$dataSourceName' --version '$version' --externalDatabaseName $extDbName $isSpeciesScope $taxonId $tp $stp";

    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertDataSource", $dbPluginArgs);

}

sub getConfigDeclaration {
    return (
           # [name, default, description]
           );
}



