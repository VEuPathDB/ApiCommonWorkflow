package ApiCommonWorkflow::Main::WorkflowSteps::DirectlyCopyBigWigToWebServices;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::Util::OrganismInfo;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $inputsDir = $self->getParamValue('inputsDir');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $relativeDir = $self->getParamValue('relativeDir');
  my $experimentDatasetName = $self->getParamValue('experimentDatasetName');

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  my $organismNameForFiles =
      $self->getOrganismInfo($test, $organismAbbrev)->getNameForFiles();

  my $outputsDir = "$websiteFilesDir/$relativeDir/$organismNameForFiles/bigwig/$experimentDatasetName";

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd_mkdir = "mkdir -p $outputsDir";

  my $cmd_cp = "cp $workflowDataDir/$inputsDir/*  $outputsDir/";

  $self->testInputFile('copyFromDir', "$workflowDataDir/$inputsDir");

  if ($undo) {
    $self->runCmd(0, "rm -fr $outputsDir");
  } else {
    $self->runCmd($test, $cmd_mkdir);
    $self->runCmd($test, $cmd_cp);
  }

}

1;


