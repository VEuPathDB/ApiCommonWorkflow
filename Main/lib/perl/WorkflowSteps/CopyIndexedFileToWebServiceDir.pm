package ApiCommonWorkflow::Main::WorkflowSteps::CopyIndexedFileToWebServiceDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;

use File::Basename;

# Used for GFF and Bed.  maybe other file types??

sub run {
  my ($self, $test, $undo) = @_;

  # standard parameters for making download files
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $copyFromFile = $self->getParamValue('copyFromFile');

  my $indexSuffix = $self->getParamValue('indexSuffix');
  my $fileType = $self->getParamValue('fileType');
  my $dataType = $self->getParamValue('dataType');

  my $copyFromBasename = basename $copyFromFile; # like someFile.gff.gz
  my $copyFromDirName = dirname $copyFromFile;  # relative path

  my $relativeWebServicesDir = $self->getParamValue('relativeWebServicesDir');

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  my $gusConfigFile = $self->getParamValue('gusConfigFile');
  $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";

  my $organismNameForFiles = $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getNameForFiles();

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $copyToDir = "$websiteFilesDir/$relativeWebServicesDir/$organismNameForFiles/${dataType}/${fileType}/";

  my $gzFile =  "${copyFromBasename}";
  my $tbiFile =  "${gzFile}.${indexSuffix}";

  #$self->testInputFile('copyFromFile', "$workflowDataDir/${copyFromDirName}/$gzFile");
  #$self->testInputFile('copyFromFile', "$workflowDataDir/${copyFromDirName}/$tbiFile");

  if($undo) {
    $self->runCmd(0, "rm -f $copyToDir/$gzFile");
    $self->runCmd(0, "rm -f $copyToDir/$tbiFile");
  } else{
    $self->runCmd($test, "mkdir -p $copyToDir");
    $self->runCmd($test, "cp $workflowDataDir/${copyFromDirName}/${gzFile} $copyToDir");
    $self->runCmd($test, "cp $workflowDataDir/${copyFromDirName}/${tbiFile} $copyToDir");
  }
}

1;
