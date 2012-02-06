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

  # extra params for this step
  my $webServicesRelativeDir = $self->getParamValue('relativeWebServicesDir');

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  my $organismNameForFiles = $self->getOrganismInfo($test, $organismAbbrev)->getNameForFiles();

  my $inputDownloadFile = ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker::getDownloadFileName($websiteFilesDir, $downloadSiteRelativeDir, $organismNameForFiles, undef, 0, $projectName, $projectVersion, 'fasta', $dataName);

  my $outputFile = ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker::getWebServiceFileName($websiteFilesDir, $webServicesRelativeDir, $organismNameForFiles, undef, 0, 'fasta', $dataName);

  if($undo) {
    $self->runCmd(0, "rm -f $outputFile*");
  } else{
      if($test){
	  $self->testInputFile('inputFile', "$inputDownloadFile");
	  $self->runCmd(0, "echo test > $outputFile");
      }else {
	  $self->runCmd($test, "cp $inputDownloadFile $outputFile");
       }
  }
}

sub getConfigDeclaration {
  return (
         # [name, default, description]
         # ['', '', ''],
         );
}

