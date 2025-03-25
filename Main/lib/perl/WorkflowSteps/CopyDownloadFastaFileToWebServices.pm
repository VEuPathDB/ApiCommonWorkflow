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
  my $gusConfigFile = $self->getParamValue('gusConfigFile');
  $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";
  # extra params for this step
  my $webServicesRelativeDir = $self->getParamValue('relativeWebServicesDir');

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  my $organismNameForFiles = $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getNameForFiles();

  my $inputDownloadFile = ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker::getDownloadFileName($websiteFilesDir, $downloadSiteRelativeDir, $organismNameForFiles, undef, 0, undef, 0, $projectName, $projectVersion, 'fasta', $dataName);

  my $outputFile = ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker::getWebServiceFileName($websiteFilesDir, $webServicesRelativeDir, $organismNameForFiles, undef, 0, undef, 0, 'fasta', $dataName, $service);

  my $mountDir = "$websiteFilesDir\/$webServicesRelativeDir\/$organismNameForFiles";

  my $indexCmd = "singularity exec -B $mountDir  docker://staphb/samtools:latest samtools faidx $outputFile";

  if($undo) {
    $self->runCmd(0, "rm -f $outputFile*");
  } else{
    $self->testInputFile('inputFile', "$inputDownloadFile");
      if($test){
	  $self->runCmd(0, "echo test > $outputFile");
      }
    $self->runCmd($test, "cp $inputDownloadFile $outputFile");
    $self->runCmd($test, $indexCmd);

  }
}

1;
