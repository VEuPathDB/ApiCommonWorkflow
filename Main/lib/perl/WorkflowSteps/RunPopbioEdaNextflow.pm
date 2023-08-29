package ApiCommonWorkflow::Main::WorkflowSteps::RunPopbioEdaNextflow;
@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::EdaNextflowConfig);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::EdaNextflowConfig;;

# could override in worfklow step if needed
my $INVESTIGATION_BASENAME = "i_investigation.txt";


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

sub getLoadProtocolTypeAsVariable {
    return "true";
}

sub getProtocolSourceId {
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
    return "report";
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

sub getOptionalAnnotationPropertiesFile { $_[0]->workflowDataPath("../annotationProperties.txt") }

1;
