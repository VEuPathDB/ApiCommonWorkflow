package ApiCommonWorkflow::Main::WorkflowSteps::MakeStudyAssayResultsNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $analysisConfigFile = $self->getParamValue("analysisConfigFile");
  my $finalDir = $self->getParamValue("finalDir");
  my $outputDirectory = $self->getParamValue("outputDirectory");
  my $technologyType = $self->getParamValue("technologyType");
  my $nextflowConfigFile = $self->getParamValue("nextflowConfigFile");

  # Platform mapping parameters from DoStudyAssayResults
  my $geneProbeMappingTabFile = $self->getParamValue('geneProbeMappingTabFile');
  my $platformDirectory = $self->getParamValue('platformDirectory');
  my $passPlatformMappingFile = $self->getBooleanParamValue('passPlatformMappingFile');
  my $expectCdfFile = $self->getBooleanParamValue('expectCdfFile');
  my $expectNdfFile = $self->getBooleanParamValue('expectNdfFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $baseConfigFile = "\$baseDir/conf/singularity.config";

  # Determine the input file based on platform mapping (logic from DoStudyAssayResults)
  my $inputFile = "NA";
  if($passPlatformMappingFile) {
    my $platformDir = "$workflowDataDir/$platformDirectory";
    opendir(DIR, $platformDir);
    my @files = readdir(DIR);
    closedir DIR;

    my $mappingFile;
    if($expectCdfFile) {
      my @cdfs = grep { /\.cdf$/i} @files;
      $self->error("cdf file error in directory $platformDir") if(scalar(@cdfs) != 1);
      $mappingFile = "$platformDir/$cdfs[0]";
    }
    elsif($expectNdfFile) {
      my @ndfs = grep { /\.ndf$/i} @files;
      $self->error("ndf file error in directory $platformDir") if(scalar(@ndfs) != 1);
      $mappingFile = "$platformDir/$ndfs[0]";
    }
    else {
      $mappingFile = $geneProbeMappingTabFile eq '' ? "$platformDir/ancillary.txt" : "$platformDir/$geneProbeMappingTabFile";
    }
    $inputFile = $mappingFile;
  }

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
  inputFile = "$inputFile"
}

includeConfig "$baseConfigFile"

NEXTFLOW

      print F $configString;
      close(F);
  }
}

1;
