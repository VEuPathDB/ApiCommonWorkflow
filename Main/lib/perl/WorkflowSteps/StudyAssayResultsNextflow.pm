package ApiCommonWorkflow::Main::WorkflowSteps::StudyAssayResultsNextflow;
@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::RunNextflow);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::RunNextflow;

sub hasPluginCalls {
    return 0;
}

sub nextflowConfigAsString {
    my ($self) = @_;

    my $workflowDataDir = $self->getWorkflowDataDir();

    my $analysisConfigFile = $self->getParamValue("analysisConfigFile");
    my $finalDir = $self->getParamValue("finalDir");
    my $technologyType = $self->getParamValue("technologyType");

    my $resultsDirectory = $self->getResultsDirectory();

    # Deliberately NOT calling getSharedClusterNextflowConfigIncludeBlock() here.
    # RunNextflow::run() execs nextflow directly (no ssh, no bsub) on whatever host
    # the ReFlow controller itself runs on -- this pipeline never dispatches to a
    # compute cluster, so the shared config's cluster-only setup (module load
    # apptainer) doesn't apply and breaks the run when included.
    my $configString = <<NEXTFLOW;
params {
  analysisConfigFile = "$workflowDataDir/$analysisConfigFile"
  finalDir = "$workflowDataDir/$finalDir"
  outputDirectory = "$resultsDirectory"
  technologyType = "$technologyType"
}

includeConfig "\$baseDir/conf/singularity.config"

cleanup = true                                

NEXTFLOW

    return $configString;
}

1;
