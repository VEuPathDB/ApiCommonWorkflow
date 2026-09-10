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

#    my $tuningTablePrefix = $self->getTuningTablePrefix($test, $self->getParamValue('organismAbbrev'), $gusConfigFile);
    my $organismAbbrev = $self->getParamValue('organismAbbrev');

    my $tRNAExtDbRlsSpec = $organismAbbrev."TRNAscan-SE|1.3";

    # tRNAscan annotation is optional: not every genome will have this
    # release loaded. getExtDbRlsId() dies (via getValueFromTable) when
    # the release doesn't exist, so wrap it in eval to fall back to
    # "no tRNA annotation" instead of failing the whole step.
    my $tRNAExtDbRlsId = eval { $self->getExtDbRlsId($test, $tRNAExtDbRlsSpec) };
    if ($@) {
      $self->log("WARN", "tRNAscan-SE release '$tRNAExtDbRlsSpec' not found for $organismAbbrev; proceeding with primary genome annotation only ($@)");
      $tRNAExtDbRlsId = undef;
      undef $@;   # explicitly clear so this failed lookup can't be mistaken for a real error by anything that checks $@ later
    }

    my $cmd = "makeGff.pl --gusConfigFile $gusConfigFile --extDbRlsId $extDbRlsId --outputFile $downloadFileName --organismAbbrev $organismAbbrev";
    $cmd = "$cmd --extDbRlsId $tRNAExtDbRlsId" if ($tRNAExtDbRlsId);
    return $cmd;
}

1;
