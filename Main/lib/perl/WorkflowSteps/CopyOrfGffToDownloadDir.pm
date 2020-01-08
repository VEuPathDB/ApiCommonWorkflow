package ApiCommonWorkflow::Main::WorkflowSteps::CopyOrfGffToDownloadDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::Util::OrganismInfo;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $copyFromFile = $self->getParamValue('copyFromFile');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $relativeDownloadDir = $self->getParamValue('relativeDownloadDir');
  my $websiteFilesDir = $self->getWebsiteFilesDir($test);
  my $organismNameForFiles =
      $self->getOrganismInfo($test, $organismAbbrev)->getNameForFiles();
  my $copyToDir = "$websiteFilesDir/$relativeDownloadDir/$organismNameForFiles/gff/data";
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd_copy = "cp $workflowDataDir/$copyFromFile $copyToDir";


  $self->testInputFile('copyFromFile', "$workflowDataDir/$copyFromFile");
  if ($undo) {
    $self->runCmd(0, "rm -f $copyToDir/Orf50.gff");
  } else {
    $self->runCmd($test, $cmd_copy);
  }

}

1;


