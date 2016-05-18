package ApiCommonWorkflow::Main::WorkflowSteps::DatasetLoaderGetAndUnpack;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $datasetName = $self->getParamValue('datasetName');
    my $datasetLoaderXmlFile = $self->getParamValue('datasetLoaderXmlFileName');
    my $dataDirPath = $self->getParamValue('dataDir');
    my $datasetLoader = $self->getDatasetLoader($datasetName, $datasetLoaderXmlFile, $dataDirPath);

    my $workflowDataDir = $self->getWorkflowDataDir();

    my $targetDir = "$workflowDataDir/$dataDirPath";

    $self->error("Target dir '$targetDir' does not exist") unless -d $targetDir;

    if ($undo) {
      $self->runCmd(0, "rm -rf $targetDir/*");
      $self->runCmd(0, "rm -rf $targetDir/.listing") if -e "$targetDir/.listing"; # created mysteriously by wget sometimes
    } else {
	$self->getDataset($test, $datasetLoader, $targetDir, $datasetName);
	$self->unpackDataset($test, $datasetLoader);
	$self->processDeclaredOutputs($test, $datasetLoader);
    }
}

sub getDataset {
    my ($self, $test, $datasetLoader, $targetDir, $datasetName) = @_;

    my $WgetArgs = $datasetLoader->getWgetArgs();
    my $manualGet = $datasetLoader->getManualGet();
    my $manualFileOrDir = $datasetLoader->getManualFileOrDir();
    my $UrlArg = $datasetLoader->getWgetUrl();

    die "DatasetLoader $datasetName must provide either <wgetArgs> or <manualGet>, but not both\n"
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

sub unpackDataset {
    my ($self, $test, $datasetLoader) = @_;

    my $unpacks =  $datasetLoader->getUnpacks();

    my @unpacks2 = map { _formatForCLI($_) } @$unpacks;

    foreach my $unpacker (@unpacks2) {
	$self->error("Empty unpack command") unless $unpacker;
	$self->runCmd($test,$unpacker);
    }
}

# the <getAndUnpackOutput> element in the datasetLoader xml file declares
# outputs.  they have an absolute path
sub processDeclaredOutputs {
  my ($self, $test, $datasetLoader) = @_;

  foreach my $declaredOutput (@{$datasetLoader->getGetAndUnpackOutputs()}) {
    my $dir = $declaredOutput->{dir};
    my $file = $declaredOutput->{file};
    if ($test) {
      $self->runCmd(0, "mkdir -p $dir") if $dir;
      $self->runCmd(0, "echo test > $file") if $file;
    } else {
      if ($dir) {
	$self->error("Declared output dir '$dir' was not created") unless -d $dir;
      } else {
	$self->error("Declared output file '$file' was not created") if (!-e $file && !-e "$file.gz");
      }
    }
  }
}

# remove line wrappings for command line processing
sub _formatForCLI {
    $_[0] =~ s/\\$//gm;
    $_[0] =~ s/[\n\r]+/ /gm;
    return $_[0];
}

1;


