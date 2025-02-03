package ApiCommonWorkflow::Main::WorkflowSteps::MakeMassSpecNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $maxForks = 5;

  my $proteinSequenceFile = $self->getParamValue("inputProteinSequenceFile");
  my $inputDir = $self->getParamValue("inputDir");
  my $inputAnnotationGff = $self->getParamValue("inputAnnotationGffFile");

  my $nextflowConfigFile = $self->getParamValue("nextflowConfigFile");
  my $resultsDirectory = $self->getParamValue("resultsDirectory");


  my $outputProteinGff = $self->getParamValue("outputPeptidesProteinAlignGff");
  my $outputGenomeGff = $self->getParamValue("outputPeptidesGenomeAlignGff");

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $workingDirRelativePath = $self->getParamValue("workingDirRelativePath");
  my $digestedInputDirectory = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $inputDir);
  my $digestedProteinFastaFile = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $proteinSequenceFile);
  my $digestedAnnotationGff = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $inputAnnotationGff);
  my $digestedOutputDir = $self->relativePathToNextflowClusterPath($workingDirRelativePath, $resultsDirectory);

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
  inputDirectory = "$digestedInputDirectory"
  proteinFastaFile = "$digestedProteinFastaFile"
  annotationGff =  "$digestedAnnotationGff"
  proteinGffFileName = "$outputProteinGff"
  genomeGffFileName = "$outputGenomeGff"
  outputDir = "$digestedOutputDir"
}


process {
    maxForks = $maxForks
}

includeConfig "$clusterConfigFile"

NEXTFLOW

      print F $configString;
      close(F);
  }
}






1;
