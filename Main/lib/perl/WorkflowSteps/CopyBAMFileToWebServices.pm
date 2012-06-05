package ApiCommonWorkflow::Main::WorkflowSteps::CopyBAMFileToWebServices;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;

sub run {
  my ($self, $test, $undo) = @_;

  # standard parameters for making download files
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $projectName = $self->getParamValue('projectName');
  my $inputFile=$self->getParamValue('inputFile');
  my $experimentName=$self->getParamValue('experimentName');
  my $snpStrain=$self->getParamValue('snpStrain');
  my $webServicesRelativeDir = $self->getParamValue('relativeWebServicesDir');

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  my $organismNameForFiles = $self->getOrganismInfo($test, $organismAbbrev)->getNameForFiles();

  my $copyToDir = "$websiteFilesDir/$webServicesRelativeDir/$organismNameForFiles/bam/$experimentName/$snpStrain/";

  if($undo) {
    $self->runCmd(0, "rm -f $copyToDir/*");
  } else{
      if($test){
	  $self->testInputFile('inputFile', "$inputFile");
	  $self->runCmd(0, "mkdir -p $copyToDir");
      }else {
	  $self->runCmd($test, "mkdir -p $copyToDir");
	  $self->runCmd($test, "cp $inputFile $copyToDir");
       }
  }
}

sub getConfigDeclaration {
  return (
         # [name, default, description]
         # ['', '', ''],
         );
}

