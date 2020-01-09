package ApiCommonWorkflow::Main::WorkflowSteps::CopyOrfGffToWebServices;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;

use File::Basename;

sub run {
  my ($self, $test, $undo) = @_;

  # standard parameters for making download files
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $copyFromFile = $self->getParamValue('copyFromFile');
  my $relativeWebServicesDir = $self->getParamValue('relativeWebServicesDir');

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  my $organismNameForFiles = $self->getOrganismInfo($test, $organismAbbrev)->getNameForFiles();

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $copyToDir = "$websiteFilesDir/$relativeWebServicesDir/$organismNameForFiles/gff/";

  $self->testInputFile('copyFromFile', "$workflowDataDir/$copyFromFile");
  if($undo) {
    $self->runCmd(0, "rm -f $copyToDir/Orf50.gff");
  } else{
    $self->runCmd($test, "cp $workflowDataDir/$copyFromFile $copyToDir");
  }
}

1;
