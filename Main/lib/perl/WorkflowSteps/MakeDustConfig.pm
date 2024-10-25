package ApiCommonWorkflow::Main::WorkflowSteps::MakeDustNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $fastaSubsetSize = 10;

  my $genomicSequenceFile = $self->getParamValue("genomicSequenceFile");
  my $nextflowConfigFile = $self->getParamValue("nextflowConfigFile");
  my $resultsDirectory = $self->getParamValue("resultsDirectory");
  my $outputFileName = $self->getParamValue("outputFileName");

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $clusterServer = $self->getSharedConfig('clusterServer');
  my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
  my $executor = $self->getClusterExecutor();

  my $clusterConfigFile = "\$baseDir/conf/${executor}.config";

  if ($undo) {
      $self->runCmd(0, "rm $workflowDataDir/$nextflowConfigFile");
  } else {
      my $nextflowConfig = "$workflowDataDir/$nextflowConfigFile";
      open(F, ">$nextflowConfig") || die "Can't open task prop file '$nextflowConfig' for writing";

      my $configString = <<NEXTFLOW;
params {
  inputFilePath = "$clusterWorkflowDataDir/$genomicSequenceFile"
  outputDir = "$clusterWorkflowDataDir/$resultsDirectory"
  outputFileName = "$outputFileName"
  fastaSubsetSize = $fastaSubsetSize
}

includeConfig "$clusterConfigFile"

NEXTFLOW

      print F $configString;
      close(F);
  }
}

1;
