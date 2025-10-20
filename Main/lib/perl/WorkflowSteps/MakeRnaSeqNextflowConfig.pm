package ApiCommonWorkflow::Main::WorkflowSteps::MakeRnaSeqNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $analysisConfigFile = $self->getParamValue("analysisConfigFile");
  my $finalDir = $self->getParamValue("finalDir");
  my $outputDirectory = $self->getParamValue("outputDirectory");
  my $technologyType = $self->getParamValue("technologyType");
  my $inputFile = $self->getParamValue("inputFile");
  my $tpmDir = $self->getParamValue("tpmDir");
  my $pseudogenesFile = $self->getParamValue("pseudogenesFile");
  my $chromosomeSizeFile = $self->getParamValue("chromosomeSizeFile");
  my $nextflowConfigFile = $self->getParamValue("nextflowConfigFile");

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $baseConfigFile = "\$baseDir/conf/singularity.config";

  if ($undo) {
      $self->runCmd(0, "rm $workflowDataDir/$nextflowConfigFile");
  } else {
      my $nextflowConfig = "$workflowDataDir/$nextflowConfigFile";
      open(F, ">$nextflowConfig") || die "Can't open nextflow config file '$nextflowConfig' for writing";

      my $configString = <<NEXTFLOW;
params {
  analysisConfigFile = "$workflowDataDir/$analysisConfigFile"
  finalDir = "$workflowDataDir/$finalDir"
  outputDirectory = "$workflowDataDir/$outputDirectory"
  technologyType = "$technologyType"
  inputFile = "$workflowDataDir/$inputFile"
  tpmDir = "$workflowDataDir/$tpmDir"
  pseudogenesFile = "$workflowDataDir/$pseudogenesFile"
  chromosomeSizeFile = "$workflowDataDir/$chromosomeSizeFile"
}

includeConfig "$baseConfigFile"

NEXTFLOW

      print F $configString;
      close(F);
  }
}

1;
