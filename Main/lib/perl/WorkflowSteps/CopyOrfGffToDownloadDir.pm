package ApiCommonWorkflow::Main::WorkflowSteps::CopyOrfGffToDownloadDir;

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
  my $relativeDownloadDir = $self->getParamValue('relativeDownloadDir');
  my $websiteFilesDir = $self->getWebsiteFilesDir($test);
  my $gusConfigFile = $self->getParamValue('gusConfigFile');
  $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";

  my $organismNameForFiles =
      $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getNameForFiles();
  my $copyToDir = "$websiteFilesDir/$relativeDownloadDir/$organismNameForFiles/gff/data";

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd_copy = "cp $workflowDataDir/$copyFromFile $copyToDir";

  my $basename = basename $copyFromFile;
  
  #$self->testInputFile('copyFromFile', "$workflowDataDir/$copyFromFile");
  if ($undo) {
    $self->runCmd(0, "rm -f $copyToDir/$basename");
  } else {
    $self->runCmd($test, $cmd_copy);
  }

}

1;


