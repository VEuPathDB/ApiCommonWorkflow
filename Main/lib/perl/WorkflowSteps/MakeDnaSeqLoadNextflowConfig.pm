package ApiCommonWorkflow::Main::WorkflowSteps::MakeDnaSeqLoadNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $indelDir          = $self->getParamValue("indelDir");
    my $extDbRlsSpec      = $self->getParamValue("extDbRlsSpec");
    my $genomeExtDbRlsSpec = $self->getParamValue("genomeExtDbRlsSpec");

    my $configPath = $self->getWorkflowDataDir() . "/" . $self->getParamValue("nextflowConfigFile");

    if ($undo) {
        $self->runCmd(0, "rm -rf $configPath");
    } else {
        open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";
        print F
"
params {
  indelDir          = \"$indelDir\"
  extDbRlsSpec      = '\"$extDbRlsSpec\"'
  genomeExtDbRlsSpec = '\"$genomeExtDbRlsSpec\"'
}

singularity {
  enabled    = true
  autoMounts = true
}
";
        close(F);
    }
}

1;
