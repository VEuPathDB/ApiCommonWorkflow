package ApiCommonWorkflow::Main::WorkflowSteps::CreateExtDbAndDbRls;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    # get parameters
    my $syntenyExtDbRlsSpec = $self->getParamValue('syntenyExtDbRlsSpec');
    my ($extDbName,$extDbRlsVer) = $self->getExtDbInfo($test,$syntenyExtDbRlsSpec);

    my $dbPluginArgs = "--name '$extDbName' ";
    
    $self->runPlugin($test, 0, "GUS::Supported::Plugin::InsertExternalDatabase", $dbPluginArgs);

    my $releasePluginArgs = "--databaseName '$extDbName' --databaseVersion '$extDbRlsVer'";

    $self->runPlugin($test, 0, "GUS::Supported::Plugin::InsertExternalDatabaseRls", $releasePluginArgs);
}


sub getParamsDeclaration {
    return (
            'syntenyExtDbRlsSpec'
           );
}

sub getConfigDeclaration {
    return (
           # [name, default, description]
           );
}



