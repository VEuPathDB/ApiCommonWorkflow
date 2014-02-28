package ApiCommonWorkflow::Main::WorkflowSteps::CopyImageFileToWebServices;

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
  my $datasetName=$self->getParamValue('datasetName');
  my $relativeAuxiliaryDir = $self->getParamValue('relativeAuxiliaryDir');

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  my $organismNameForFiles = $self->getOrganismInfo($test, $organismAbbrev)->getNameForFiles();

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $copyToDir = "$websiteFilesDir/$relativeAuxiliaryDir/$organismNameForFiles/image/$datasetName/";

  if($undo) {
    $self->runCmd(0, "rm -f $copyToDir/*");
  } else{
      if($test){
        $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
        $self->runCmd(0, "mkdir -p $copyToDir");
      }else {
        $self->runCmd($test, "mkdir -p $copyToDir");
        $self->runCmd($test, "cp $workflowDataDir/$inputFile/* $copyToDir");
       }
  }
}

sub getConfigDeclaration {
  return (
         # [name, default, description]
         # ['', '', ''],
         );
}

