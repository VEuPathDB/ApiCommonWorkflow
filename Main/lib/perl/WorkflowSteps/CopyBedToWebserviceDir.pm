package ApiCommonWorkflow::Main::WorkflowSteps::CopyBedToWebserviceDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::Util::OrganismInfo;

use File::Basename;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $copyFromFile = $self->getParamValue('copyFromFile');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $relativeWebServicesDir = $self->getParamValue('relativeWebServicesDir');
  my $websiteFilesDir = $self->getWebsiteFilesDir($test);
  my $copyToDirectory = $self->getParamValue('copyToDirectory');

  my $organismNameForFiles =
      $self->getOrganismInfo($test, $organismAbbrev)->getNameForFiles();
  my $copyToDir = "$websiteFilesDir/$relativeWebServicesDir/$organismNameForFiles/$copyToDirectory/";

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd_copy = "mkdir -p $copyToDir && cp $workflowDataDir/$copyFromFile $copyToDir";

  my $basename = basename $copyFromFile;
  
  $self->testInputFile('copyFromFile', "$workflowDataDir/$copyFromFile");
  if ($undo) {
    $self->runCmd(0, "rm -f $copyToDir/$basename/$copyFromFile");
  } else {
    $self->runCmd($test, $cmd_copy);
  }

}

1;


