package ApiCommonWorkflow::Main::WorkflowSteps::DatasetLoaderRunPlugin;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $datasetName = $self->getParamValue('datasetName');
    my $datasetLoaderXmlFile = $self->getParamValue('datasetLoaderXmlFileName');
    my $dataDirPath = $self->getParamValue('dataDir');
    my $datasetLoader = $self->getDatasetLoader($datasetName, $datasetLoaderXmlFile, $dataDirPath);
    my $parentDatasetLoader = $datasetLoader->getParentDatasetLoader();
    
    # if version is TODAY, get value from db instead
    my $versionFromDb;
    my $ds = $parentDatasetLoader? $parentDatasetLoader : $datasetLoader;
    if ($ds->getRawVersion() eq 'TODAY') {
	$versionFromDb = $self->getExtDbVersion($test, $ds->getName());
    }

    my $plugin =  $datasetLoader->getPlugin();
    my $pluginArgs = $datasetLoader->getPluginArgs($versionFromDb);

    _formatForCLI($pluginArgs);

    if ($plugin =~ m/InsertSequenceFeatures/ && $undo){

      my $mapFile = $1 if ($pluginArgs =~ m/mapFile\s+(\S+)\s+/);

      my $algInvIds = $self->getAlgInvIds();
      
      if ($algInvIds) {
	  $self->runCmd($test,"ga GUS::Supported::Plugin::InsertSequenceFeaturesUndo --mapFile $mapFile --algInvocationId $algInvIds --gusConfigFile  --workflowContext --commit");
      } else {
	$self->log("No algorithm invocation IDs found for this plugin step.  The plugin must have been manually undone.  Exiting");
      }
	
    }else{

	$self->runPlugin($test, $undo, $plugin, $pluginArgs);
    }
}

sub _formatForCLI {
    $_[0] =~ s/\\$//gm;
    $_[0] =~ s/[\n\r]+/ /gm;
}


1;

