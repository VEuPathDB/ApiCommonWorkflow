package ApiCommonWorkflow::Main::WorkflowSteps::CopyDownloadFastaFileToWebServices;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;

sub run {
  my ($self, $test, $undo) = @_;

  # standard parameters for making download files
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $projectName = $self->getParamValue('projectName');
  my $projectVersion = $self->getParamValue('projectVersionForWebsiteFiles');
  my $downloadSiteRelativeDir = $self->getParamValue('relativeDownloadSiteDir');  
  my $dataName = $self->getParamValue('dataName');
  my $service = $self->getParamValue('service');

  # extra params for this step
  my $webServicesRelativeDir = $self->getParamValue('relativeWebServicesDir');

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  my $organismNameForFiles = $self->getOrganismInfo($test, $organismAbbrev)->getNameForFiles();

  my $inputDownloadFile = ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker::getDownloadFileName($websiteFilesDir, $downloadSiteRelativeDir, $organismNameForFiles, undef, 0, undef, 0, $projectName, $projectVersion, 'fasta', $dataName);

  $self->runCmd(0, "gunzip $inputDownloadFile.gz") if(-e "$inputDownloadFile.gz");

  my $outputFile = ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker::getWebServiceFileName($websiteFilesDir, $webServicesRelativeDir, $organismNameForFiles, undef, 0, undef, 0, 'fasta', $dataName, $service);

  if($undo) {
    $self->runCmd(0, "rm -f $outputFile*");
  } else{
    $self->testInputFile('inputFile', "$inputDownloadFile");
      if($test){
	  $self->runCmd(0, "echo test > $outputFile");
      }
    $self->runCmd($test, "cp $inputDownloadFile $outputFile");

    $self->runCmd($test, "gzip $inputDownloadFile") unless(-e "$inputDownloadFile.gz");
  }
}

1;
