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
    my $parentRsrc = $dataSource->getParentResource();

    # if has a parentResource, validate that the resource exists
    # and, if not in test mode, that it is in the database
    if ($parentRsrc) {
      my $parentDatasource = $self->getDataSource($parentRsrc, $dataSourceXmlFile, $dataDirPath);
      my $parentVersion = $parentDatasource->getVersion();
      if (!$test) {
	my $parentExtDbRlsId = $self->getExtDbRlsId($test, "$parentRsrc|$parentVersion");
	$self->error("Resource $dataSourceName declares a parentResource=$parentRsrc.  But the parent is not found in the database (with version $parentVersion)") unless $parentExtDbRlsId;
      }
    }

    # otherwise insert this ext db rls
    else {

      my $releasePluginArgs = "--databaseName '$dataSourceName' --databaseVersion '$dataSourceVersion'";

      $self->runPlugin($test, 0, "GUS::Supported::Plugin::InsertExternalDatabaseRls", $releasePluginArgs);
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



