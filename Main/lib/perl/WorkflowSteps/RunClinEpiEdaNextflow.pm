package ApiCommonWorkflow::Main::WorkflowSteps::RunClinEpiEdaNextflow;
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
    return sprintf("%s/ontology/release/production/%s.owl",
      $ENV{GUS_HOME}, $_[0]->getParamValue('webDisplayOntologyName'));
} # for mapping, can be ontologyMapping.xml or dataset-specific owl

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
    return "TODO";
}

# TODO:
# relative paths: '/../final/owlAttributes.txt'
sub getOptionalDateObfuscationFile {return $_[0]->workflowDataPath("../final/dateObfuscation.txt") }
sub getOptionalValueMappingFile { return $_[0]->workflowDataPath("../final/valueMap.txt") }
sub getOptionalOntologyMappingOverrideFile { return $_[0]->workflowDataPath("../final/ontologyMapping.xml") }
# sub getOptionalEntityTypeFile { return "entities.txt" }
# sub getOptionalOwlAttributesFile { return "owlAttributes.txt" }
# sub getOptionalOrdinalsFile { return "ordinals.txt" }
sub getOptionalAnnotationPropertiesFile { $_[0]->workflowDataPath("../annotationProperties.txt") }


1;
