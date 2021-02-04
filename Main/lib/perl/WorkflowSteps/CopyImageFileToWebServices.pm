package ApiCommonWorkflow::Main::WorkflowSteps::CopyImageFileToWebServices;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;

use Image::Magick;
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
    #$self->runCmd(0, "rm -f $copyToDir/*");
    $self->runCmd(0, "find $copyToDir -name '*' -exec rm -f {} \\;");
  } else{
    $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
    if($test){
      $self->runCmd(0, "mkdir -p $copyToDir");
    }else {
      $self->runCmd($test, "mkdir -p $copyToDir");
      #$self->runCmd($test, "cp $workflowDataDir/$inputFile/* $copyToDir");
      # if there are too many image files
      $self->runCmd($test, "find $workflowDataDir/$inputFile/ -name '*' -exec cp {} $copyToDir \;");

      # convert tif file to jpeg format. later should use Image::Info to check image type
      opendir(DIR, "$workflowDataDir/$inputFile/");
      while(my $f = readdir(DIR)) {
        next unless $f =~ /(\.tif|\.tiff)$/i;
        my $image = Image::Magick->new;
        $image->Read("$workflowDataDir/$inputFile/$f");
        $image->Set (compression=>"JPEG", quality=>90);
        #$f =~ s/(\.tif|\.tiff)$//i;
        $image->Write ("$copyToDir/$f.jpg");
      }
      closedir(DIR);
    }
  }
}

1;
