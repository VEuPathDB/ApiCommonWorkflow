package ApiCommonWorkflow::Main::WorkflowSteps::CopyExpressionProfilesToDownloadDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::Util::OrganismInfo;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $copyFromDir = $self->getParamValue('copyFromDir');
  my $configFile = $self->getParamValue('configFile');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  # this is relative to the website files dir.
  # it will look something like downloadSite/ToxoDB/release-6.3
  my $relativeDir = $self->getParamValue('relativeDir');

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  my $organismNameForFiles =
      $self->getOrganismInfo($test, $organismAbbrev)->getNameForFiles();

  my $copyToDir = "$websiteFilesDir/$relativeDir/$organismNameForFiles/transcriptExpression";

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "copyExpressionProfilesToDownloadDir --inputDir $workflowDataDir/$copyFromDir  --outputDir $copyToDir --configFile $workflowDataDir/$configFile";

  if ($test) {
    $self->testInputFile('copyFromDir', "$workflowDataDir/$copyFromDir");
  }

  if ($undo) {
    $self->runCmd(0, "rm -fr $copyToDir/*");
  } else {
    $self->runCmd($test, $cmd);
  }

}

sub getParamsDeclaration {
  return (
          'copyFromDir',
          'organismAbbrev',
          'relativeDir',
          'configFile',
         );
}

sub getConfigDeclaration {
  return (
         # [name, default, description]
         # ['', '', ''],
         );
}


