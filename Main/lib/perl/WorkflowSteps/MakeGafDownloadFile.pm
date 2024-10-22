package ApiCommonWorkflow::Main::WorkflowSteps::MakeGafDownloadFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::Util::OrganismInfo;

sub getWebsiteFileCmd {
    my ($self, $downloadFileName, $test) = @_;

    my $extDbRlsId = $self->getExtDbRlsId($test,$self->getParamValue('genomeExtDbRlsSpec'));
    my $gusConfigFile = $self->getParamValue('gusConfigFile');
    $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";

    my $tuningTablePrefix = $self->getTuningTablePrefix($test, $self->getParamValue('organismAbbrev'), $gusConfigFile);

    my $organismAbbrev = $self->getParamValue('organismAbbrev');


    return "makeGafFile4Download.pl --organismAbbrev $organismAbbrev --tuningTablePrefix $tuningTablePrefix --outputFile $downloadFileName";
}

1;
