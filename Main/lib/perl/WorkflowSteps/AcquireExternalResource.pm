package ApiCommonWorkflow::Main::WorkflowSteps::AcquireExternalResource;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use GUS::Pipeline::ExternalResources::Loader;
use GUS::Pipeline::ExternalResources::RepositoryWget;
use GUS::Pipeline::ExternalResources::RepositoryManualGet;

sub run {
    my ($self, $test, $undo) = @_;

    my $dataSourceName = $self->getParamValue('dataSourceName');
    $self->{dataSource} = $self->getDataSource($dataSourceName);
    my $WgetArgs=  $self->{dataSource}->getWgetArgs();
    my $manualArgs=  $self->{dataSource}->getManualArgs();
    my $UrlArg=  $self->{dataSource}->getUrl();


    my $usingWget = $WgetArgs || $UrlArg;
    die "Resource $dataSourceName must provide either an url and WgetArgs or ManualArgs, but not both\n " if ($usingWget && $manualArgs);
    my $args;

    my $localDataDir = $self->getLocalDataDir();

    my $targetDir="$localDataDir/$dataSourceName";

    $self->runCmd(0,"mkdir -p $targetDir");

    if ($undo) {
      $self->runCmd(0, "rm -fr $targetDir");
    } else {
	if ($test) {
	    $self->runCmd(0,"echo hello > $targetDir/test.txt");
	}

	if ($WgetArgs) {
	    my $cmd = "wget --directory-prefix=$targetDir --output-file=$logFile $WgetArgs \"$UrlArg\"";
	    $self->runCmd($test, $cmd);
	}else{
	    $args = $manualArgs;
	    $self->{manualGet} = GUS::Pipeline::ExternalResources::RepositoryManualGet->new($args);
	    $self->acquireByManualGet($targetDir);
	}
    }
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



