package ApiCommonWorkflow::Main::WorkflowSteps::RunMBioEdaNextflow;
@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::EdaNextflowConfig);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::EdaNextflowConfig;;

# could override in worfklow step if needed


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
    return "isatab";
}
sub getInvestigationBaseName { return sprintf("../final/%s.xml", $_[0]->getParamValue("studyStableId")) }

sub getDownloadFileBaseName {
    return "";
}

sub getOptionalCollectionsYaml {
    return sprintf("%s/ontology/General/collections/collections.yaml", $ENV{GUS_HOME});
}

sub getSampleDetailsFile { return sprintf("../final/%s.txt", $_[0]->getParamValue("studyStableId")) }
sub getAssayResultsDirectory { return "../final" }
sub getAssayResultsFileExtensionsJson { sprintf("%s/ApiCommonData/Load/ontology/Microbiome/assayExtensions", $ENV{PROJECT_HOME} ) }

# TODO:
# relative paths: '/../final/owlAttributes.txt'
# sub getOptionalDateObfuscationFile {return $_[0]->workflowDataPath("../final/dateObfuscation.txt") }
sub getOptionalValueMappingFile { return $_[0]->workflowDataPath("../final/valueMap.txt") }
sub getOptionalOntologyMappingOverrideFile { return $_[0]->workflowDataPath("../final/ontologyMapping.xml") }
# sub getOptionalEntityTypeFile { return "entities.txt" }
# sub getOptionalOwlAttributesFile { return "owlAttributes.txt" }
# sub getOptionalOrdinalsFile { return "ordinals.txt" }
sub getOptionalAnnotationPropertiesFile { $_[0]->workflowDataPath("../annotationProperties.txt") }

sub workflowDataPath {
  my ($self, $file) = @_;
  return join("/",$self->getStudyDirectory() , $file);
}

1;
