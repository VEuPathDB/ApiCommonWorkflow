package ApiCommonWorkflow::Main::WorkflowSteps::CopyDownloadFilesDirFromManualDelivery;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;

sub run {
  my ($self, $test, $undo) = @_;

  my $projectName = $self->getParamValue('projectName');
  my $relativeManualDeliveryDir = $self->getParamValue('relativeManualDeliveryDir');  
  my $relativeDownloadSiteDir = $self->getParamValue('relativeDownloadSiteDir');

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);
  my $manualDeliveryDir = $self->getSharedConfig('manualDeliveryDir');

  my $inputDir = "$manualDeliveryDir/$projectName/$relativeManualDeliveryDir";
  my $outputDir = "$websiteFilesDir/downloadSite/$projectName/release-CURRENT/$relativeDownloadSiteDir";

  if($undo) {
    $self->runCmd(0, "rm -r $outputDir");
  } else {
    if (-e $inputDir) {
      my @files = glob "$inputDir";
      if (scalar @files<1) {
        warn "No input files. Please check inputDir: $inputDir\n";
      } else {
        if ($test) {
          $self->runCmd(0, "mkdir -p $outputDir");
          $self->runCmd(0, "echo test > $outputDir/test");
        }
        $self->runCmd($test, "mkdir -p $outputDir");
        $self->runCmd($test, "cp $inputDir/* $outputDir");
      }
    } else {
      warn "Directory not found: $inputDir";
    }
  }
}

1;
