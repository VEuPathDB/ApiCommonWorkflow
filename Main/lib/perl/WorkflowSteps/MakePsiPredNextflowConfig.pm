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
    my $workingDirRelativePath = $self->getParamValue("workingDirRelativePath");

    my $executor = $self->getClusterExecutor();
    my $clusterConfigFile = "\$baseDir/conf/${executor}.config";

    if ($undo) {
        $self->runCmd(0, "rm $workflowDataDir/$nextflowConfigFile");

    } else {
      my $nextflowConfig = "$workflowDataDir/$nextflowConfigFile";
      open(F, ">$nextflowConfig") || die "Can't open task prop file '$nextflowConfig' for writing";

      my $proteinSequenceFileInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $proteinSequenceFile);
      my $resultsDirectoryInNextflowWorkingDirOnCluster = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $resultsDirectory);
      my $configString = <<NEXTFLOW;
params {
  inputFilePath = "$proteinSequenceFileInNextflowWorkingDirOnCluster"
  outputDir = "$resultsDirectoryInNextflowWorkingDirOnCluster"
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

NEXTFLOW
      print F $configString;
	close(F);
    }
}

1;
