package ApiCommonWorkflow::Main::WorkflowSteps::MakeWebServicesMotifFastaFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # standard parameters for making download files
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $projectName = $self->getParamValue('projectName');
  my $projectVersion = $self->getParamValue('projectVersion');
  my $downloadSiteRelativeDir = $self->getParamValue('relativeDownloadSiteDir');  my $dataName = $self->getParamValue('dataName');

  # extra params for this step
  my $webServicesRelativeDir = $self->getParamValue('relativeWebServicesDir');

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  # get download site file
  my $organismNameForFiles = $self->getOrganismInfo($test, $organismAbbrev)->getNameForFiles();
  my $downloadFileDir = "$websiteFilesDir/$downloadSiteRelativeDir/$organismNameForFiles/fasta";
  my $fileName = "$projectName-${projectVersion}_${organismNameForFiles}_$dataName.fasta";
  my $inputDownloadFile = "$downloadFileDir/$fileName";

  # outputFile
  my $outputFile = "$websiteFilesDir/$webServicesRelativeDir/$organismNameForFiles/motif/$fileName";

  if($undo) {
    $self->runCmd(0, "rm -f $outputFile*");
  } else{
      if($test){
	  $self->testInputFile('inputFile', "$inputFile");
	  $self->runCmd(0, "echo test > $outputFile");
      }else {
	  $self->runCmd($test, "cp $inputFile $outputFile");	   
       }
  }
}

sub getConfigDeclaration {
  return (
         # [name, default, description]
         # ['', '', ''],
         );
}

