package ApiCommonWorkflow::Main::WorkflowSteps::MakeGffDownloadFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub getWebsiteFileCmd {
    my ($self, $downloadFileName, $test) = @_;

    my $extDbRlsId = $self->getExtDbRlsId($test,$self->getParamValue('genomeExtDbRlsSpec'));
    my $gusConfigFile = $self->getParamValue('gusConfigFile');
    $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";

    my $tuningTablePrefix = $self->getTuningTablePrefix($test, $self->getParamValue('organismAbbrev'), $gusConfigFile);

    return "makeGff.pl --gusConfigFile $gusConfigFile --extDbRlsId $extDbRlsId --outputFile $downloadFileName --tuningTablePrefix $tuningTablePrefix";
}

1;
