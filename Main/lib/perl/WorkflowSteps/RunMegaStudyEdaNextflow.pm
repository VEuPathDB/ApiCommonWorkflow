package ApiCommonWorkflow::Main::WorkflowSteps::RunMegaStudyEdaNextflow;
@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::EdaNextflowConfig);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::EdaNextflowConfig;;

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


sub getMegaStudyStableId {
    my ($self) = @_;
    return $self->getParamValue('studyStableId');
}

sub getOptionalMegaStudyYaml {
    my ($self) = @_;
    return $self->getWorkingDirectory() . "/final/" . $self->getParamValue('megaStudyYamlBaseName');
}

sub getDownloadFileBaseName {
    return "TODO";
}

1;
