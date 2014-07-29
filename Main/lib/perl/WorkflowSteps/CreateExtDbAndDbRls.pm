package ApiCommonWorkflow::Main::WorkflowSteps::CreateExtDbAndDbRls;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    # get parameters
    my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');
    my ($extDbName, $extDbRlsVer) = $self->getExtDbInfo($test, $extDbRlsSpec);

    my $dbPluginArgs = "--name '$extDbName' ";
    
    $self->runPlugin($test, 0, "GUS::Supported::Plugin::InsertExternalDatabase", $dbPluginArgs);

    my $releasePluginArgs = "--databaseName '$extDbName' --databaseVersion '$extDbRlsVer'";

    $self->runPlugin($test, 0, "GUS::Supported::Plugin::InsertExternalDatabaseRls", $releasePluginArgs);

    if ($undo) {
        $self->runPlugin($test, $undo, "GUS::Supported::Plugin::InsertExternalDatabaseRls", $releasePluginArgs); 
        $self->runPlugin($test, $undo, "GUS::Supported::Plugin::InsertExternalDatabase", $dbPluginArgs);
    }
}


1;



