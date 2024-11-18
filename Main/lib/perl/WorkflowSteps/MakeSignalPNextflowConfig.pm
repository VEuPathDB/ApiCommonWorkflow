package ApiCommonWorkflow::Main::WorkflowSteps::MakeSignalPNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # can change these in config if needed
  my $fastaSubsetSize = 500;
  my $signalPFilterScoreCutoff = 0.1;
  my $signalPMinProteinPercentCutoff = 20;
  my $signalP6ProteinCountLimit = 6000; # if the filtered protein file has more than this number of proteins, we don't run signalp6

  my $proteinSequenceFile = $self->getParamValue("proteinSequenceFile");
  my $nextflowConfigFile = $self->getParamValue("nextflowConfigFile");
  my $resultsDirectory = $self->getParamValue("resultsDirectory");
  my $outputFileName = $self->getParamValue("outputFileName");

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $clusterServer = $self->getSharedConfig('clusterServer');

  # Expecting something like "/project/eupathdb/apptainerImages"
  my $apptainerImageDirectory = $self->getSharedConfig("$clusterServer.apptainerImageDirectory");

  # Expecting something like "/project/eupathdb/apptainerImages" + "/" + signalp/latest/signalp.sif
  my $sifImageFile = ${apptainerImageDirectory} . "/" . $self->getSharedConfig("signalpImageRelativePath");

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
  inputFilePath = "$clusterWorkflowDataDir/$proteinSequenceFile"
  outputDir = "$clusterWorkflowDataDir/$resultsDirectory"
  outputFileName = "$outputFileName"
  fastaSubsetSize = $fastaSubsetSize
}


process {
    maxForks = 5

    withName: filterInputFastaByResults {
        ext.filter_score_cutoff = $signalPFilterScoreCutoff
        ext.filter_min_protein_percent_cutoff = $signalPMinProteinPercentCutoff
    }

     withLabel: signalp {
        container = "${sifImageFile}"
        ext.org = "euk"
    }

    withName: signalp6 {
        ext.protein_count_limit = $signalP6ProteinCountLimit
    }

}

includeConfig "$clusterConfigFile"

NEXTFLOW

      print F $configString;
      close(F);
  }
}



1;
