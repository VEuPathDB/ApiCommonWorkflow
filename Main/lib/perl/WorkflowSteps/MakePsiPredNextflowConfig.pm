package ApiCommonWorkflow::Main::WorkflowSteps::MakePsiPredNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    my $fastaSubsetSize = 100;
    my $maxForks = 10;

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();

    my $proteinSequenceFile = $self->getParamValue("proteinSequenceFile");
    my $nextflowConfigFile = $self->getParamValue("nextflowConfigFile");
    my $resultsDirectory = $self->getParamValue("resultsDirectory");
    my $outputFilePrefix = $self->getParamValue("outputFilePrefix");

    my $executor = $self->getClusterExecutor();
    my $clusterConfigFile = "\$baseDir/conf/${executor}.config";

    if ($undo) {
        $self->runCmd(0, "rm $workflowDataDir/$nextflowConfigFile");

    } else {
      my $nextflowConfig = "$workflowDataDir/$nextflowConfigFile";
      open(F, ">$nextflowConfig") || die "Can't open task prop file '$nextflowConfig' for writing";

    print F
"
params {
  inputFilePath = "$clusterWorkflowDataDir/$proteinSequenceFile"
  outputDir = "$clusterWorkflowDataDir/$resultsDirectory"
  outputFilePrefix = "$outputFilePrefix"
  fastaSubsetSize = $fastaSubsetSize
}

process {
    maxForks = $maxForks

    withName: filterAndMakeIndividualFiles {
        ext.max_sequence_length = 10000
    }
}


includeConfig "$clusterConfigFile"
";
	close(F);
    }
}

1;
