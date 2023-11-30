package ApiCommonWorkflow::Main::WorkflowSteps::RunMegaStudyEdaNextflow;
@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::EdaNextflowConfig);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::EdaNextflowConfig;;

# couls override these defaults in worflow if necessary;
my $MEGASTUDY_YAML = "/../final/megaStudy.yaml";
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

sub getLoadWebDisplayOntologyFile {
    return "false";
}

sub getOptionalCollectionsYaml {
    return sprintf("%s/ontology/General/collections/popbio.yaml", $ENV{GUS_HOME});
}


sub getMegaStudyStableId {
    my ($self) = @_;
    return $self->getParamValue('studyStableId');
}

sub getOptionalMegaStudyYaml {
    my ($self) = @_;
    return $self->getWorkingDirectory() . $MEGASTUDY_YAML;;
}


 sub getOptionalAnnotationPropertiesFile {
     my ($self) = @_;
     return $self->getWorkingDirectory() . $ANNOTATION_PROPERTIES_FILE;
 }


sub getDownloadFileBaseName {
    return $_[0]->getParamValue('downloadFileBaseName');
}

1;
