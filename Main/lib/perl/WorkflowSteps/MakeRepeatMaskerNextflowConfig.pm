package ApiCommonWorkflow::Main::WorkflowSteps::MakeRepeatMaskerNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use Data::Dumper;

sub run {
    my ($self, $test, $undo) = @_;

    my $maxForks = $self->getParamValue("maxForks");

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


    my $clusterServer = $self->getSharedConfig("clusterServer");
    my $repeatMaskerDatabase = join("/", $self->getSharedConfig("$clusterServer.softwareDatabasesDirectory"),$self->getSharedConfig("repeatMaskerDatabaseDirectory"),$famdbRelativePath);

    my $executor = $self->getClusterExecutor();
    my $clusterConfigFile = "\$baseDir/conf/${executor}.config";

    my $organismAbbrev = $self->getParamValue('organismAbbrev');

    my $speciesNcbiTaxonId= $self->getParamValue('speciesNcbiTaxonId');

    #my $speciesName = $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getSpeciesNameFromNcbiTaxId($speciesNcbiTaxonId);

     my $speciesNcbiTaxonIdOverride = $self->getConfig('speciesNcbiTaxonIdOverride',1);
     if ($speciesNcbiTaxonIdOverride) {
    #     my ($speciesToOverride, $speciesThatOverrides) = split(/,\s*/, $speciesOverride);
    #     #|| die "Config property speciesOverride has an invalid value: '$speciesOverride'.  It must be of the form 'speciesToOverride, speciesThatOverrides'\n";
    #     $speciesName = $speciesThatOverrides if $speciesName eq $speciesToOverride;
       $speciesNcbiTaxonId = $speciesNcbiTaxonIdOverride;
     }

    if ($undo) {
	$self->runCmd(0,"rm -rf $configPath");
    } else {
	open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";

    my $configString = <<NEXTFLOW;
params {
  inputFilePath = "$inputFilePath"
  fastaSubsetSize = $fastaSubsetSize
  trimDangling = $trimDangling
  dangleMax = $dangleMax
  rmParams = "$rmParams"
  taxonId = $speciesNcbiTaxonId
  outputFileName = "$outputFileName"
  errorFileName = "$errorFileName"
  outputDir = "$outputDir"
}

process{
  maxForks = $maxForks
}

includeConfig "$clusterConfigFile"

singularity {
  runOptions = "--bind ${repeatMaskerDatabase}:/opt/RepeatMasker/Libraries/famdb"
}


NEXTFLOW
    print F $configString;
    close(F);

    }
}

1;
