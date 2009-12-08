package ApiCommonWorkflow::Main::WorkflowSteps::AcquireExternalResource;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $dataSourceName = $self->getParamValue('dataSourceName');
    my $dataSource = $self->getDataSource($dataSourceName);
    my $WgetArgs=  $dataSource->getWgetArgs();
    my $manualArgs=  $dataSource->getManualArgs();
    my $UrlArgs=  $dataSource->getUrl();

    my $usingWget = $WgetArgs || $UrlArgs;
    die "Resource $dataSourceName must provide either an url and WgetArgs or ManualArgs, but not both\n " if ($usingWget && $manualArgs);
    my $args;
    if($usingWget){
	$args = GUS::Pipeline::ExternalResources::Loader::_parseWgetArgs(substr($WgetArgs,0,length($WgetArgs)));
	$args->{url} = $UrlArgs;
    }else{
	$args = $manualArgs;
    }

    $self->runPlugin($test, $undo, $plugin, $pluginArgs);
}


sub getParamsDeclaration {
    return (
            'dataSourceName'
           );
}

sub getConfigDeclaration {
    return (
           # [name, default, description]
           );
}



