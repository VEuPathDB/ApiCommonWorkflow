package ApiCommonWorkflow::Main::WorkflowSteps::CopyNormalizedBedGraphToWebServiceDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::Util::OrganismInfo;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $copyFromDir = $self->getParamValue('copyFromDir');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $relativeDir = $self->getParamValue('relativeDir');

  my $experimentDatasetName = $self->getParamValue('experimentDatasetName');

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  my $organismNameForFiles =
      $self->getOrganismInfo($test, $organismAbbrev)->getNameForFiles();

  my $copyToDir = "$websiteFilesDir/$relativeDir/$organismNameForFiles/bigwig/$experimentDatasetName";

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd_mkdir = "mkdir -p $copyToDir";

  my $analysisConfig = "$workflowDataDir/$copyFromDir/$experimentDatasetName/final/analysisConfig.xml";

  my $cmd_copy = "copyNormalizedBedGraphToWebServiceDir.pl --inputDir $workflowDataDir/$copyFromDir  --outputDir $copyToDir --analysisConfig $analysisConfig"; 



  $self->testInputFile('copyFromDir', "$workflowDataDir/$copyFromDir");

  if ($undo) {
    $self->runCmd(0, "rm -fr $copyToDir");
  } else {
    $self->runCmd($test, $cmd_mkdir);
    $self->runCmd($test, $cmd_copy);
  }

}

1;


