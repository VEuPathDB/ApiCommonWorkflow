package ApiCommonWorkflow::Main::WorkflowSteps::ResourceGetAndUnpack;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $dataSourceName = $self->getParamValue('resourceName');
    my $dataSourceXmlFile = $self->getParamValue('resourceXmlFileName');
    my $dataDirPath = $self->getParamValue('dataDir');
    my $dataSource = $self->getDataSource($dataSourceName, $dataSourceXmlFile, $dataDirPath);

    my $workflowDataDir = $self->getWorkflowDataDir();

    my $targetDir = "$workflowDataDir/$dataDirPath";

    $self->error("Target dir '$targetDir' does not exist") unless -d $targetDir;

    if ($undo) {
      $self->runCmd(0, "rm -fr $targetDir/*");
    } else {
	$self->getResource($test, $dataSource, $targetDir);
	$self->unpackResource($test, $dataSource, $targetDir);
	$self->processDeclaredOutputs($test, $dataSource);
    }
}

sub getResource {
    my ($self, $test, $dataSource, $targetDir, $dataSourceName) = @_;

    my $WgetArgs = $dataSource->getWgetArgs();
    my $manualGet = $dataSource->getManualGet();
    my $manualFileOrDir = $dataSource->getManualFileOrDir();
    my $UrlArg = $dataSource->getWgetUrl();

    die "Resource $dataSourceName must provide either <wgetArgs> or <manualGet>, but not both\n"
	unless ($WgetArgs && !$manualGet) || ($manualGet && !$WgetArgs);

    if ($WgetArgs) {
        my $logFile = $self->getStepDir() . "/wget.log";
	my $cmd = "wget --directory-prefix=$targetDir --output-file=$logFile $WgetArgs \"$UrlArg\"";
	$self->runCmd($test, $cmd);
	unless ($test){
	    my $wgetLogTail = $self->runCmd($test, "tail -2 $logFile|grep -i '[saved|FINISHED]'");
	    $self->error ("Wget did not successfully run. Check log file: $logFile\n") unless ($wgetLogTail);
	}
    } else {
	my $manualDeliveryDir = $self->getSharedConfig('manualDeliveryDir');
	if ($test) {
	    -e "$manualDeliveryDir/$manualFileOrDir" || $self->error("Manual delivery file or dir '$manualDeliveryDir/$manualFileOrDir' does not exist");
	} else {
	    my $cmd="cp -Lr $manualDeliveryDir/$manualFileOrDir $targetDir";
	    $self->runCmd($test, $cmd);
	}
    }
}

sub unpackResource {
    my ($self, $test, $dataSource) = @_;

    my $unpacks =  $dataSource->getUnpacks();

    my @unpacks2 = map { _formatForCLI($_) } @$unpacks;

    foreach my $unpacker (@unpacks2) {
	print STDERR "$unpacker\n";
	$self->runCmd($test,$unpacker);
    }
}

# the <getAndUnpackOutput> element in the resources xml file declares
# outputs.  they have an absolute path
sub processDeclaredOutputs {
  my ($self, $test, $dataSource) = @_;

  foreach my $declaredOutput (@{$dataSource->getGetAndUnpackOutputs()}) {
    my $dir = $declaredOutput->{dir};
    my $file = $declaredOutput->{file};
    if ($test) {
      $self->runCmd(0, "mkdir -p $dir") if $dir;
      $self->runCmd(0, "echo test > $file") if $file;
    } else {
      if ($dir) {
	$self->error("Declared output dir '$dir' was not created") unless -d $dir;
      } else {
	$self->error("Declared output file '$file' was not created") unless  -e $file;
      }
    }
  }
}

# remove line wrappings for command line processing
sub _formatForCLI {
    $_[0] =~ s/\\$//gm;
    $_[0] =~ s/[\n\r]+/ /gm;
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



