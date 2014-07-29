 package ApiCommonWorkflow::Main::WorkflowSteps::FormatDownloadFilesFromManualDelivery;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $projectName = $self->getParamValue('projectName');
  my $outputDir = $self->getParamValue('outputDir');
  my $formattedFileName = $self->getParamValue('formattedFileName');
  my $formatterArgs = $self->getParamValue('args');

  my $ncbiBlastPath = $self->getConfig('ncbiBlastPath');
  my $websiteFilesDir = $self->getWebsiteFilesDir($test);
  my $fileToFormat = "$websiteFilesDir/downloadSite/$projectName/release-CURRENT/$inputFile";
  my $formattedOutputDir = "$websiteFilesDir/webServices/$projectName/release-CURRENT/$outputDir";
  my $formattedFile = "$formattedOutputDir/$formattedFileName";

  if ($undo) {
    $self->runCmd(0, "rm -f  $formattedFile*");
    $self->runCmd(0, "rm -r  $formattedOutputDir");
  } else {
      if ($test) {
          $self->runCmd(0, "mkdir -p $formattedOutputDir");
	  $self->runCmd(0,"echo test >  $formattedFile");
      }
    $self->runCmd($test, "mkdir -p $formattedOutputDir");
    $self->runCmd($test,"$ncbiBlastPath/makeblastdb -in $fileToFormat $formatterArgs -out $formattedFile");
  }
}


1;

