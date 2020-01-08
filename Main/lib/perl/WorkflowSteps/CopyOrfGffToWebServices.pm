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
  my $relativeCopyFromFile = $self->getParamValue('relativeCopyFromFile');
  my $relativeWebServicesDir = $self->getParamValue('relativeWebServicesDir');

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  my $organismNameForFiles = $self->getOrganismInfo($test, $organismAbbrev)->getNameForFiles();

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $copyToDir = "$websiteFilesDir/$webServicesRelativeDir/$organismNameForFiles/gff/";

  $self->testInputFile('relativeCopyFromFile', "$workflowDataDir/$organismAbbrev/$relativeCopyFromFile");
  if($undo) {
    $self->runCmd(0, "rm -f $copyToDir/Orf50.gff");
  } else{
    $self->runCmd($test, "cp $workflowDataDir/$organismAbbrev/$relativeCopyFromFile $copyToDir");
  }
}

1;
