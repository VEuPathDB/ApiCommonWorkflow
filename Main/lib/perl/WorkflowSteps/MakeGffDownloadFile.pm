package ApiCommonWorkflow::Main::WorkflowSteps::MakeGffDownloadFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub getWebsiteFileCmd {
    my ($self, $downloadFileName, $test) = @_;

    my $extDbRlsId = $self->getExtDbRlsId($test,$self->getParamValue('genomeExtDbRlsSpec'));

    my $tuningTablePrefix = $self->getTuningTablePrefix($self->getParamValue('organismAbbrev'), $test);

    return "makeGff.pl --extDbRlsId $extDbRlsId --outputFile $downloadFileName --tuningTablePrefix $tuningTablePrefix";
}

1;
