package ApiCommonWorkflow::Main::WorkflowSteps::EdaNextflowConfig;
@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::RunNextflow);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::RunNextflow;

sub workflowDataPath {
  my ($self, $file) = @_;
  return join("/",$self->getStudyDirectory() , $file);
}


# eda nextflow makes an extra directory in the working directory for downloads
sub run {
    my ($self, $test, $undo) = @_;

    $self->SUPER::run($test, $undo);

    if($undo) {
        my $workingDirectory = $self->getWorkingDirectory();
        my $resultsDir = $self->getParamValue("resultsDir");
        $self->runCmd(0, "rm -rf $workingDirectory/$resultsDir");
    }
}


sub getStudyDirectory {}
sub getProject {}
sub getExtDbRlsSpec {}

sub getWebDisplayOntologySpec {}
sub getWebDisplayOntologyFile {}
sub getLoadWebDisplayOntologyFile {}

sub getInvestigationSubset {}
sub getIsaFormat {}
sub getInvestigationBaseName {}

sub getMegaStudyStableId {}
sub getOptionalMegaStudyYaml {}

# this one is for any files written by nextflow (downloads ...)
# sub getResultsDirectory {
#   my ($self) = @_;
#   return $self->getParamValue("resultsDir");
# 
#   #my $workingDirectory = $self->getWorkingDirectory();
# 
#   #return $workingDirectory . "/" . $self->getParamValue("resultsDir");
# }


sub getIsRelativeAbundance {
  return "false";
}
sub getAssayResultsDirectory {}
sub getAssayResultsFileExtensionsJson {}
sub getSampleDetailsFile {}

sub getOptionalDateObfuscationFile {}
sub getOptionalValueMappingFile {}
sub getOptionalOntologyMappingOverrideFile {}

sub getDownloadFileBaseName {}

sub getOptionalAnnotationPropertiesFile {}

sub getSpeciesReconciliationOntologySpec {}
sub getSpeciesReconciliationFallbackSpecies {}
sub getGadmDataDir {}
sub getGadmSocketDir {}
sub getGadmPort { }

sub getLoadProtocolTypeAsVariable {}
sub getProtocolVariableSourceId {}

sub getOptionalCollectionsYaml {}

sub getUseOntologyTermTableForTaxonTerms {
    return "false"
}

sub getNoCommonDef {}


sub getSchema {
    return "EDA"
}


sub nextflowConfigAsString {
    my ($self) = @_;

    my $studyDirectory = $self->getStudyDirectory() || "NA";
    my $project = $self->getProject() || "NA";
    my $extDbRlsSpec = $self->getExtDbRlsSpec() || "NA";
    my $webDisplayOntologySpec = $self->getWebDisplayOntologySpec() || "NA";
    my $webDisplayOntologyFile = $self->getWebDisplayOntologyFile() || "NA";
    my $loadWebDisplayOntologyFile = $self->getLoadWebDisplayOntologyFile() || "NA";
    my $investigationSubset = $self->getInvestigationSubset() || "NA";
    my $schema = $self->getSchema() || "NA";
    my $isaFormat = $self->getIsaFormat() || "NA";
    my $investigationBaseName = $self->getInvestigationBaseName() || "NA";
    my $megaStudyStableId = $self->getMegaStudyStableId() || "NA";
    my $optionalMegaStudyYaml = $self->getOptionalMegaStudyYaml() || "NA";

    my $resultsDir = $self->getResultsDirectory() || "NA";

    my $isRelativeAbundance = $self->getIsRelativeAbundance();
    my $assayResultsDirectory = $self->getAssayResultsDirectory() || "NA";
    my $assayResultsFileExtensionsJson = $self->getAssayResultsFileExtensionsJson() || "NA";
    my $sampleDetailsFile = $self->getSampleDetailsFile() || "NA";
    my $optionalDateObfuscationFile = $self->getOptionalDateObfuscationFile() || "NA";
    my $optionalValueMappingFile = $self->getOptionalValueMappingFile() || "NA";
    my $optionalOntologyMappingOverrideFile = $self->getOptionalOntologyMappingOverrideFile() || "NA";

    my $downloadFileBaseName = $self->getDownloadFileBaseName() || "NA";
    my $speciesReconciliationOntologySpec = $self->getSpeciesReconciliationOntologySpec() || "NA";
    my $speciesReconciliationFallbackSpecies = $self->getSpeciesReconciliationFallbackSpecies() || "NA";
    my $gadmDataDirectory = $self->getGadmDataDir() || "NA";
    my $gadmSocketDirectory = $self->getGadmSocketDir() || "NA";
    my $gadmPort = $self->getGadmPort() || "NA";
    my $loadProtocolTypeAsVariable = $self->getLoadProtocolTypeAsVariable() || "false";
    my $protocolVariableSourceId = $self->getProtocolVariableSourceId() || "NA";
    my $optionalAnnotationPropertiesFile = $self->getOptionalAnnotationPropertiesFile() || "NA";

    my $useOntologyTermTableForTaxonTerms = $self->getUseOntologyTermTableForTaxonTerms();

    my $optionalCollectionsYaml = $self->getOptionalCollectionsYaml() || "NA";
    my $optionalNoCommonDef = $self->getNoCommonDef() || "NA";

    my $config = <<CONFIG;
params.studyDirectory = "$studyDirectory"
params.project = "$project"
params.extDbRlsSpec = "$extDbRlsSpec"

params.webDisplayOntologySpec = "$webDisplayOntologySpec"
params.webDisplayOntologyFile = "$webDisplayOntologyFile"
params.loadWebDisplayOntologyFile = $loadWebDisplayOntologyFile

params.investigationSubset = "$investigationSubset"

params.schema = "$schema"
params.isaFormat = "$isaFormat"
params.investigationBaseName = "$investigationBaseName"

params.megaStudyStableId = "$megaStudyStableId"
params.optionalMegaStudyYaml = "$optionalMegaStudyYaml"

params.resultsDirectory = "$resultsDir"

params.assayResultsDirectory = "$assayResultsDirectory"
params.assayResultsFileExtensionsJson = "$assayResultsFileExtensionsJson"
params.sampleDetailsFile = "$sampleDetailsFile"

// optional files when isaFormat = simple
params.optionalDateObfuscationFile = "$optionalDateObfuscationFile"
params.optionalValueMappingFile = "$optionalValueMappingFile"
params.optionalOntologyMappingOverrideFile = "$optionalOntologyMappingOverrideFile"

// optional ontology files
params.optionalAnnotationPropertiesFile = "$optionalAnnotationPropertiesFile"

params.downloadFileBaseName = "$downloadFileBaseName"

params.speciesReconciliationOntologySpec = "$speciesReconciliationOntologySpec"
params.speciesReconciliationFallbackSpecies = "$speciesReconciliationFallbackSpecies"
params.useOntologyTermTableForTaxonTerms = $useOntologyTermTableForTaxonTerms

params.optionalGadmDataDirectory = "$gadmDataDirectory";
params.optionalGadmSocketDirectory = "$gadmSocketDirectory";
params.optionalGadmPort = "$gadmPort";

params.loadProtocolTypeAsVariable = $loadProtocolTypeAsVariable
params.protocolVariableSourceId = "$protocolVariableSourceId"

// needed for Mbio otu data
params.isRelativeAbundance = $isRelativeAbundance

params.optionalCollectionsYaml = "$optionalCollectionsYaml"

params.noCommonDef = "$optionalNoCommonDef"

trace.enabled = true
trace.fields = 'task_id,hash,process,tag,status,exit,submit,realtime,%cpu,rss'
CONFIG

    return $config;
}


1;
