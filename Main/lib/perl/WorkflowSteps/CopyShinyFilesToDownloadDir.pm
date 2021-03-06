package ApiCommonWorkflow::Main::WorkflowSteps::CopyShinyFilesToDownloadDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

use Digest::SHA qw(sha1_hex);

sub run {
  my ($self, $test, $undo) = @_;

  my $datasetName = $self->getParamValue('datasetName');
  my $nameForFilenames= $self->getParamValue('nameForFilenames');
  my $groupName = $self->getParamValue('groupName');
  my $inputFileBaseName = $self->getParamValue('inputFileBaseName');
  my $downloadDir = $self->getParamValue('relativeDownloadSiteDir');

  # standard parameters for making download files
  my $websiteFilesDir = $self->getWebsiteFilesDir($test);
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $digest = sha1_hex($datasetName);
  my $copyToDir = "$websiteFilesDir/$downloadDir/$digest";

  if($undo) {
    $self->runCmd(0, "rm -f $copyToDir/*");
  } else{
      if($test){
	  $self->runCmd(0, "mkdir -p $copyToDir");
      }
    $self->runCmd($test, "mkdir -p $copyToDir");
    $self->runCmd($test, "printf \"IndexIgnore *\" > $websiteFilesDir/$downloadDir/.htaccess");
    $self->runCmd($test, "printf \"IndexIgnoreReset ON\nIndexIgnore ..\" > $copyToDir/.htaccess");
    if($nameForFilenames){
      $self->runCmd($test, "rename $inputFileBaseName $nameForFilenames $workflowDataDir/$datasetName/$inputFileBaseName*");
      $self->runCmd($test, "cp $workflowDataDir/$datasetName/$nameForFilenames* $copyToDir/");
    }
    else{
      $self->runCmd($test, "rename $inputFileBaseName $datasetName $workflowDataDir/$datasetName/$inputFileBaseName*");
      $self->runCmd($test, "cp $workflowDataDir/$datasetName/$datasetName* $copyToDir/");
    }
  }
}

1;
