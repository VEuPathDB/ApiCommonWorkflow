package ApiCommonWorkflow::Main::WorkflowSteps::RunPopsetEdaNextflow;
@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::EdaNextflowConfig);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::EdaNextflowConfig;;

# could override in worfklow step if needed
my $INVESTIGATION_BASENAME = "investigation.xml";


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
    return "$webDisplayOntologyName|dontcare"
}

sub getWebDisplayOntologyFile {
    return sprintf("%s/%s", $ENV{GUS_HOME}, $_[0]->getParamValue('webDisplayOntologyFile'));
}

sub getLoadProtocolTypeAsVariable {
    return "false";
}

sub getLoadWebDisplayOntologyFile {
    return "true"; # if you want to load the getWebDisplayOntologyFile above IF IT IS OWL
## SEE eda-nextflow/main.nf
}

sub getInvestigationSubset {
    return "../final";
}

sub getIsaFormat {
    return "simple";
}
sub getInvestigationBaseName {
    return $INVESTIGATION_BASENAME;
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
    return "/eupath/data/EuPathDB/manualDelivery/common/gadm/4.1/postgresData";
    my $proj = $self->getParamValue('projectName');
    my $workflowDataDir = $self->getWorkflowDataDir();
    return "${workflowDataDir}/global/${proj}_gadm_RSRC/postgresData";
}

sub getGadmSocketDir {
    my ($self) = @_;
    return "/eupath/data/EuPathDB/manualDelivery/common/gadm/4.1/postgresSocket";
    my $proj = $self->getParamValue('projectName');
    my $workflowDataDir = $self->getWorkflowDataDir();
    return "${workflowDataDir}/global/${proj}_gadm_RSRC/postgresSocket";
}


sub getOptionalCollectionsYaml {
    return sprintf("%s/ontology/General/collections/collections.yaml", $ENV{GUS_HOME});
}
sub getOptionalStudyStableId {
    return $_[0]->getParamValue('studyName');
}

sub getGusConfigFile { return "NA" }
# TODO:
# relative paths: '/../final/owlAttributes.txt'
# sub getOptionalDateObfuscationFile {return $_[0]->workflowDataPath("../final/dateObfuscation.txt") }
sub getOptionalValueMappingFile { return $_[0]->workflowDataPath("../final/valueMap.txt") }
sub getOptionalOntologyMappingOverrideFile { return $_[0]->workflowDataPath("../final/ontologyMapping.xml") }
# sub getOptionalEntityTypeFile { return "entities.txt" }
# sub getOptionalOwlAttributesFile { return "owlAttributes.txt" }
# sub getOptionalOrdinalsFile { return "ordinals.txt" }
sub getOptionalAnnotationPropertiesFile { $_[0]->workflowDataPath("../annotationProperties.txt") }

sub getNoCommonDef { return "true" }

1;
