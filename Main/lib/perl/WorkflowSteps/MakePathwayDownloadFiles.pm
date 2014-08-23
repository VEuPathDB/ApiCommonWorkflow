package ApiCommonWorkflow::Main::WorkflowSteps::MakePathwayDownloadFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $gusConfigFile= "$ENV{GUS_HOME}/config/gus.config";
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $relativeDownloadSiteDir =  $self->getParamValue('relativeDownloadSiteDir');
  my $outputDirName = $self->getParamValue('outputDirName');
  my $outputDir = $self->getParamValue('relativeDownloadSiteDir') . '/' . $outputDirName;
  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  my $cmd = "makePathwayImgDataFiles.pl --gusConfigFile $gusConfigFile --outputDir $websiteFilesDir/$outputDir --pathwayList ALL";

  if ($undo) {
    $self->runCmd(0, "rm -Rf $websiteFilesDir/$outputDir");
  }else {
    $self->runCmd($test, "mkdir -p $websiteFilesDir/$outputDir");
    $self->runCmd($test, $cmd);
  }
}

1;
