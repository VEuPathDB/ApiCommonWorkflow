package ApiCommonWorkflow::Main::WorkflowSteps::ResourceInsertExtDbRls;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $dataSourceName = $self->getParamValue('resourceName');
    my $dataSourceXmlFile = $self->getParamValue('resourceXmlFileName');
    my $dataDirPath = $self->getParamValue('dataDir');
    my $dataSource = $self->getDataSource($dataSourceName, $dataSourceXmlFile, $dataDirPath);

    my $dataSourceVersion =  $dataSource->getVersion();
    my $parentDatasource = $dataSource->getParentResource();
    my $idType = $dataSource->getExternalDbIdType();
    my $idIsAlias = $dataSource->getExternalDbIdIsAlias();
    my $idUrl = $dataSource->getExternalDbIdUrl();
    my $idUrlUseSecondary = $dataSource->getExternalDbIdUrlUseSecondaryId();

    # if has a parentResource, validate that the resource exists
    # and, if not in test mode, that it is in the database
    if ($parentDatasource) {
      my $parentVersion = $parentDatasource->getVersion();
      my $parentName = $parentDatasource->getName();
      $self->error("Resource $dataSourceName declares a parentResource=$parentName.  It is therefore not allowed to use any of these attribues:  externalDbIdType, externalDbIdIsAlias, externalDbIdUrl, externalDbIdUrlUseSecondaryId")
	  if ($idType || $idIsAlias || $idUrl || $idUrlUseSecondary);
      if (!$test) {
	my $parentExtDbRlsId = $self->getExtDbRlsId($test, "$parentName|$parentVersion");
	$self->error("Resource $dataSourceName declares a parentResource=$parentName.  But the parent is not found in the database (with version $parentVersion)") unless $parentExtDbRlsId;
      }
    }

    # otherwise insert this ext db rls
    else {
      $idType = $idType? "--idType '$idType'" : "";
      $idIsAlias = $idIsAlias eq 'true'? "--idIsAlias" : "";
      if ($idUrl) {
	  $self->error("Resource $dataSourceName declares an externalDbIdUrl so must provide an externalDbIdUrlUseSecondaryId that is either 'true' or 'false'") unless $idUrlUseSecondary =~ /true|false/;
	  $idUrl = $idUrlUseSecondary? "--secondaryIdUrl '$idUrl'" : "--idUrl '$idUrl'";
      } else {
	  $idUrl = "";
      }

      my $releasePluginArgs = "--databaseName '$dataSourceName' --databaseVersion '$dataSourceVersion' $idType $idIsAlias $idUrl";

      $self->runPlugin($test, $undo, "GUS::Supported::Plugin::InsertExternalDatabaseRls", $releasePluginArgs);
    }
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



