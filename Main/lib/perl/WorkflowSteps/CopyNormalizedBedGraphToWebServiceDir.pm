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
  # my $analysisConfig = $self->getParamValue('analysisConfig'); restore for rebuild
  my $experimentResourceName = $self->getParamValue('experimentDatasetName');

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  my $organismNameForFiles =
      $self->getOrganismInfo($test, $organismAbbrev)->getNameForFiles();

  my $copyToDir = "$websiteFilesDir/$relativeDir/$organismNameForFiles/bigwig/$experimentResourceName";

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd_mkdir = "mkdir -p $copyToDir";

  #my $cmd_copy = "copyNormalizedBedGraphToWebServiceDir.pl --inputDir $workflowDataDir/$copyFromDir  --outputDir $copyToDir --analysisConfig $analysisConfig"; restore for rebuild
  my $cmd_copy = "copyNormalizedBedGraphToWebServiceDir.pl --inputDir $workflowDataDir/$copyFromDir  --outputDir $copyToDir"; 


  $self->testInputFile('copyFromDir', "$workflowDataDir/$copyFromDir");

  if ($undo) {
    $self->runCmd(0, "rm -fr $copyToDir");
  } else {
    $self->runCmd($test, $cmd_mkdir);
    $self->runCmd($test, $cmd_copy);
  }

}

1;


