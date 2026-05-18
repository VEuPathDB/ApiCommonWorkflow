package ApiCommonWorkflow::Main::WorkflowSteps::FilterPseudogeneProteins;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use File::Basename;

sub run {
    my ($self, $test, $undo) = @_;

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $proteomesDir    = join("/", $workflowDataDir, $self->getParamValue("proteomesDir"));
    my $gusConfigFile   = join("/", $workflowDataDir, $self->getParamValue("gusConfigFile"));

    my $outputDir  = dirname($proteomesDir);
    my $fastasBase = basename($proteomesDir);

    if ($undo) {
        $self->runCmd(0, "rm -f $outputDir/$fastasBase.tar.gz");
    } elsif ($test) {
        $self->runCmd(0, "echo 'test filterPseudogeneProteins'");
    } else {
        $self->runCmd(0, "filterPseudogeneProteins --fastaDir $proteomesDir --gusConfigFile $gusConfigFile");
    }
}

1;
