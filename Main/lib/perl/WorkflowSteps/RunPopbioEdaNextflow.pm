package ApiCommonWorkflow::Main::WorkflowSteps::RunPopbioEdaNextflow;
@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::EdaNextflowConfig);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::EdaNextflowConfig;;

# could override in worfklow step if needed
my $INVESTIGATION_BASENAME = "i_investigation.txt";
my $ANNOTATION_PROPERTIES_FILE = "/../final/annotationProperties.txt";

sub getStudyDirectory {
    my ($self) = @_;

    return $self->getWorkingDirectory();
}

sub getProject {
    my ($self) = @_;
    return $self->getParamValue('projectName');
}

sub getExtDbRlsSpec {
    my ($self) = @_;

    my $datasetName = $self->getParamValue('datasetName');
    my $datasetVersion = $self->getParamValue('datasetVersion');

    return "$datasetName|$datasetVersion";
}

sub getWebDisplayOntologySpec {
    my ($self) = @_;
    my $webDisplayOntologyName = $self->getParamValue('webDisplayOntologyName');
    return "$webDisplayOntologyName|%"
}


sub getOptionalCollectionsYaml {
    return sprintf("%s/ontology/General/collections/popbio.yaml", $ENV{GUS_HOME});
}

sub getLoadProtocolTypeAsVariable {
    return "false";
}

sub getProtocolVariableSourceId {
    return "OBI_0000272";
}

sub getLoadWebDisplayOntologyFile {
    return "false";
}

sub getInvestigationSubset {
    return "../final";
}

sub getIsaFormat {
    return "isatab";
}
sub getInvestigationBaseName {
    return $INVESTIGATION_BASENAME;;
}

sub getDownloadFileBaseName {
    return $_[0]->getParamValue('downloadFileBaseName');
}

sub getGadmPort {
    my ($self) = @_;
    return $self->getSharedConfig('gadmPort');
}

sub getGadmDataDir {
    my ($self) = @_;

    my $workflowDataDir = $self->getWorkflowDataDir();
    return "${workflowDataDir}/global/gadm_RSRC/postgresData";
}

sub getGadmSocketDir {
    my ($self) = @_;

    my $workflowDataDir = $self->getWorkflowDataDir();
    return "${workflowDataDir}/global/gadm_RSRC/postgresSocket";
}


sub getSpeciesReconciliationOntologySpec {
    my ($self) = @_;

    return $self->getParamValue('speciesReconciliationOntologySpec');

}

sub getSpeciesReconciliationFallbackSpecies {
    my ($self) = @_;

    return $self->getParamValue('speciesReconciliationFallbackSpecies');
}

sub getUseOntologyTermTableForTaxonTerms {
    return "true"
}

sub getOptionalAnnotationPropertiesFile {
     my ($self) = @_;
     return $self->getWorkingDirectory() . $ANNOTATION_PROPERTIES_FILE;
 }


1;
