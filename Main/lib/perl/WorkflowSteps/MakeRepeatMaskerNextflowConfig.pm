package ApiCommonWorkflow::Main::WorkflowSteps::MakeRepeatMaskerNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use Data::Dumper;

sub run {
    my ($self, $test, $undo) = @_;

    my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
    my $workflowDataDir = $self->getWorkflowDataDir();
    my $gusConfigFile = $self->getParamValue("gusConfigFile");
    $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";
    # We use the shared config 'repeatMaskerDatabaseDirectory' to specify the repeatMasker database version, and also as a variable in the path for webservices. The famdbRelativePath is the path inside of the repeatMaskerDatabaseDirectory that actually holds the database files to be mapped into the repeatmasker container
    my $famdbRelativePath = "Libraries/famdb";

    my $inputFilePath = join("/", $clusterWorkflowDataDir, $self->getParamValue("inputFilePath")); 
    my $outputDir = join("/", $clusterWorkflowDataDir, $self->getParamValue("outputDir")); 
    my $configFileName = $self->getParamValue("configFileName");
    my $configPath = join("/", $workflowDataDir,  $self->getParamValue("analysisDir"), $self->getParamValue("configFileName"));
    my $fastaSubsetSize = $self->getParamValue("fastaSubsetSize");
    my $trimDangling = $self->getParamValue("trimDangling");
    my $dangleMax = $self->getParamValue("dangleMax");
    my $rmParams = $self->getParamValue("rmParams");
    my $outputFileName = $self->getParamValue("outputFileName");
    my $errorFileName = $self->getParamValue("errorFileName");
    my $increasedMemory = $self->getParamValue("increasedMemory");
    my $initialMemory = $self->getParamValue("initialMemory");
    my $maxForks = $self->getParamValue("maxForks");
    my $maxRetries = $self->getParamValue("maxRetries");
    my $clusterServer = $self->getSharedConfig("clusterServer");
    my $repeatMaskerDatabase = join("/", $self->getSharedConfig("$clusterServer.softwareDatabasesDirectory"),$self->getSharedConfig("repeatMaskerDatabaseDirectory"),$famdbRelativePath);

    my $executor = $self->getClusterExecutor();
    my $queue = $self->getClusterQueue();

    my $organismAbbrev = $self->getParamValue('organismAbbrev');

    my $speciesNcbiTaxId = $self->getParamValue('speciesNcbiTaxonId');
    my $speciesName = $self->getOrganismInfo($test, $organismAbbrev)->getSpeciesNameFromNcbiTaxId($speciesNcbiTaxId);

    my $speciesOverride = $self->getConfig('speciesOverride',1);
    if ($speciesOverride) {
        my ($speciesToOverride, $speciesThatOverrides) = split(/,\s*/, $speciesOverride);
        #|| die "Config property speciesOverride has an invalid value: '$speciesOverride'.  It must be of the form 'speciesToOverride, speciesThatOverrides'\n";
        $speciesName = $speciesThatOverrides if $speciesName eq $speciesToOverride;
    }

    if ($undo) {
	$self->runCmd(0,"rm -rf $configPath");
    } else {
	open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";

    print F
"
params {
  inputFilePath = \"$inputFilePath\"
  fastaSubsetSize = $fastaSubsetSize
  trimDangling = $trimDangling
  dangleMax = $dangleMax
  rmParams = \"$rmParams -species $speciesName\"
  outputFileName = \"$outputFileName\"
  errorFileName = \"$errorFileName\"
  outputDir = \"$outputDir\"
}

process{
  container = 'veupathdb/repeatmasker'
  executor = \'$executor\'
  queue = \'$queue\'
  maxForks = $maxForks
  maxRetries = $maxRetries
  withName: 'runRepeatMasker' {
    errorStrategy = { task.exitStatus in 130..140 ? \'retry\' : \'finish\' }
    clusterOptions = {
      (task.attempt > 1 && task.exitStatus in 130..140)
        ? \'-M $increasedMemory -R \"rusage [mem=$increasedMemory] span[hosts=1]\"\'
        : \'-M $initialMemory -R \"rusage [mem=$initialMemory] span[hosts=1]\"\'
    }
  }                                                                                                                                                                             \
}
singularity {
  enabled = true
  autoMounts = true
  runOptions = \"--bind $repeatMaskerDatabase:/opt/RepeatMasker/Libraries/famdb\"
}
";
	close(F);
    }
}

1;
