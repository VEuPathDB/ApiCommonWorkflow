package ApiCommonWorkflow::Main::WorkflowSteps::DatasetLoaderInsertExtDbRls;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $datasetName = $self->getParamValue('datasetName');
    my $datasetLoaderXmlFile = $self->getParamValue('datasetLoaderXmlFileName');
    my $dataDirPath = $self->getParamValue('dataDir');
    my $datasetLoader = $self->getDatasetLoader($datasetName, $datasetLoaderXmlFile, $dataDirPath);

    my $datasetLoaderVersion =  $datasetLoader->getVersion();
    my $releaseDate = $datasetLoader->getReleaseDate();
    my $parentDatasetLoader = $datasetLoader->getParentDatasetLoader();
    my $idType = $datasetLoader->getExternalDbIdType();
    my $idIsAlias = $datasetLoader->getExternalDbIdIsAnAlias();
    my $idUrl = $datasetLoader->getExternalDbIdUrl();
    my $idUrlUseSecondary = $datasetLoader->getExternalDbIdUrlUseSecondaryId();

    # if has a parentDatasetName, validate that the datasetLoader exists
    # and, if not in test mode, that it is in the database
    if ($parentDatasetLoader) {
      my $parentVersion = $parentDatasetLoader->getVersion();
      my $parentName = $parentDatasetLoader->getName();
      $self->error("DatasetLoader $datasetName declares a parentDatasetName=$parentName.  It is therefore not allowed to use any of these attribues:  externalDbIdType, externalDbIdIsAlias, externalDbIdUrl, externalDbIdUrlUseSecondaryId, releaseDate")
	  if ($idType || $idIsAlias || $idUrl || $idUrlUseSecondary || $releaseDate);
      if (!$test) {
	my $parentExtDbRlsId = $self->getExtDbRlsId($test, "$parentName|$parentVersion");
	$self->error("DatasetLoader $datasetName declares a parentDatasetName=$parentName.  But the parent is not found in the database (with version $parentVersion)") unless $parentExtDbRlsId;
      }
    }

    # otherwise insert this ext db rls
    else {
      $idType = $idType? "--idType '$idType'" : "";
      $idIsAlias = $idIsAlias? "--idIsAlias" : "";
      $self->error("DatasetLoader $datasetName declares releaseDate=$releaseDate.  The value is not in dd-mmm-yy format (eg 27-MAR-12).") if ($releaseDate && $releaseDate !~ /^\d\d-\D\D\D-\d\d$/);
      my $rlsDt = $releaseDate? "--releaseDate $releaseDate" : "";
      if ($idUrl) {
	  $idUrl = $idUrlUseSecondary? "--secondaryIdUrl '$idUrl'" : "--idUrl '$idUrl'";
      } else {
	  $idUrl = "";
      }

      my $releasePluginArgs = "--databaseName '$datasetName' --databaseVersion '$datasetLoaderVersion' $idType $idIsAlias $idUrl $rlsDt";

      $self->runPlugin($test, $undo, "GUS::Supported::Plugin::InsertExternalDatabaseRls", $releasePluginArgs);
    }
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



