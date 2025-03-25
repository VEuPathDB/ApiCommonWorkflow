package ApiCommonWorkflow::Main::WorkflowSteps::LoadChromosomeMap;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $extDbRlsId = $self->getExtDbRlsId($test,$self->getParamValue('genomeExtDbRlsSpec'));
    my $organismAbbrev = $self->getParamValue('organismAbbrev');
    my $chromosomeMapFile = $self->getParamValue('chromosomeMapFile');
    my $genomeVersion = $self->getParamValue('genomeVersion');
    my $workflowDataDir = $self->getWorkflowDataDir();
    my $gusConfigFile = $self->getGusConfigFile();

    my $cmd = "patchChrAndChrOrderNum.pl --gusConfigFile $gusConfigFile --extDbRlsId $extDbRlsId --organismAbbrev $organismAbbrev --chromosomeMapFile $workflowDataDir/$chromosomeMapFile --genomeVersion $genomeVersion";

    if ($undo) {
      $self->runCmd(0,"echo undoing LoadChromosomeMap ... nothing to be done");
    } else {
      $self->runCmd ($test, $cmd);
    }
}

1;
