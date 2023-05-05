package ApiCommonWorkflow::Main::WorkflowSteps::CopyStableIdsEventsToDownloadDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::Util::OrganismInfo;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $projectName = $self->getParamValue('projectName');
  my $copyFromFile = $self->getParamValue('copyFromFile');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $relativeDownloadDir = $self->getParamValue('relativeDownloadSiteDir');
  my $experimentName = $self->getParamValue('experimentName');
  my $websiteFilesDir = $self->getWebsiteFilesDir($test);
  my $organismNameForFiles =
      $self->getOrganismInfo($test, $organismAbbrev)->getNameForFiles();
  my $copyToDir = "$websiteFilesDir/$relativeDownloadDir/$organismNameForFiles/txt/";
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd_copy = "cp $workflowDataDir/$copyFromFile $copyToDir/${projectName}-CURRENT_${organismNameForFiles}_${experimentName}.tab";

  $self->testInputFile('copyFromFile', "$workflowDataDir/$copyFromFile");
  if ($undo) {
    $self->runCmd(0, "rm -f $copyToDir/${projectName}-CURRENT_${organismNameForFiles}_${experimentName}.tab");
  } else {
    $self->runCmd($test, $cmd_copy);
  }

}

1;


