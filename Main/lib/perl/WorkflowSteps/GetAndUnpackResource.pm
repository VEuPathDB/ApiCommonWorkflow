package ApiCommonWorkflow::Main::WorkflowSteps::GetAndUnpackResource;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $commonTargetDir =  $self->getParamValue('commonTargetDir');
    my $dataSourceName = $self->getParamValue('dataSourceName');
    my $dataSource = $self->getDataSource($dataSourceName);

    my $localDataDir = $self->getLocalDataDir();
    my $targetDir = "$localDataDir/$dataSourceName";

    if ($undo) {
      $self->runCmd(0, "rm -fr $targetDir");
    } else {
	my $commonDoneFlag;
	if ($commonTargetDir) {
	    $targetDir = $commonTargetDir;
	    $commonDoneFlag = "$commonTargetDir/commonResourceAlreadyAcquired";
	}
	if ($commonDoneFlag && -e $commonDoneFlag) {
	    $self->log("common resource already acquired");
	} else {
	    $self->getResource($test, $dataSource, $targetDir);
	    $self->unpackResource($test, $dataSource, $targetDir);
	    if ($commonDoneFlag) {
		open(F, $commonDoneFlag) || die "Can't open common done flag '$commonDoneFlag'";
		print F "common resource acquired  by step " . $self->getName() ."\n";
		close(F);
	    }
	}
    }
}

sub getResource {
    my ($self, $test, $dataSource, $targetDir, $dataSourceName) = @_;

    my $WgetArgs = $dataSource->getWgetArgs();
    my $manualArgs = $dataSource->getManualFileOrDir();
    my $UrlArg = $dataSource->getUrl();
    
    die "Resource $dataSourceName must provide either an URL and WgetArgs or ManualArgs, but not both\n"
	unless
	(($WgetArgs && $UrlArg && !$manualArgs)
	 || ($manualArgs && !$WgetArgs && !$manualArgs));

    $self->runCmd(0,"mkdir -p $targetDir");

    if ($WgetArgs) {
        my $logFile = $self->getStepDir() . "/wget.log";
	my $cmd = "wget --directory-prefix=$targetDir --output-file=$logFile $WgetArgs \"$UrlArg\"";
	$self->runCmd($test, $cmd);
    } else {
	my $manualDeliveryDir = $self->getGlobalProperty('manualDeliveryDir');
	$manualArgs=~/.*="(.*)"/;
	my $cmd='cp -r "$manualDeliveryDir/$manualFileOrDir" $targetDir';
	$self->runCmd($test, $cmd);
    }
}

sub unpackResource {
    my ($self, $test, $dataSource) = @_;

    my $unpacks =  $dataSource->getUnpacks();
  
    my @unpacks2 = map { _formatForCLI($_) } @$unpacks;

    foreach my $unpacker (@unpacks2) {
	$self->runCmd($test,$unpacker);
    }
}

# remove line wrappings for command line processing
sub _formatForCLI {
    $_[0] =~ s/\\$//gm;
    $_[0] =~ s/[\n\r]+/ /gm;
}


sub getParamsDeclaration {
    return (
	'dataSourceName',
	'commonTargetDir'
           );
}

sub getConfigDeclaration {
    return (
           # [name, default, description]
           );
}



