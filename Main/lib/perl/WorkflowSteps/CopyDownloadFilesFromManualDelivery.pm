package ApiCommonWorkflow::Main::WorkflowSteps::CopyDownloadFilesFromManualDelivery;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;

sub run {
  my ($self, $test, $undo) = @_;

  my $projectName = $self->getParamValue('projectName');
  my $relativeManualDeliveryDir = $self->getParamValue('relativeManualDeliveryDir');  
  my $relativeDownloadSiteDir = $self->getParamValue('relativeDownloadSiteDir');
  my $inputFileNameRegex = $self->getParamValue('inputFileNameRegex');

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);
  my $manualDeliveryDir = $self->getSharedConfig('manualDeliveryDir');

  my $inputFile = " $manualDeliveryDir/$projectName/$relativeManualDeliveryDir/*${inputFileNameRegex}";
  my $outputDir = "$websiteFilesDir/downloadSite/$projectName/release-CURRENT/$relativeDownloadSiteDir";

  if($undo) {
    $self->runCmd(0, "rm -f $outputDir/*${inputFileNameRegex}");
    $self->runCmd(0, "rm -r $outputDir");
  } else{
      if($test){
	  $self->testInputFile('inputFile', "$inputFile");
          $self->runCmd(0, "mkdir -p $outputDir");
	  $self->runCmd(0, "echo test > $outputDir/test${inputFileNameRegex}");
      }else {
          $self->runCmd($test, "mkdir -p $outputDir");
	  $self->runCmd($test, "cp $inputFile $outputDir");
       }
  }
}

sub getConfigDeclaration {
  return (
         # [name, default, description]
         # ['', '', ''],
         );
}

