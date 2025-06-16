package ApiCommonWorkflow::Main::WorkflowSteps::CopyDnaseqBigwig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::Util::OrganismInfo;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $copyFromDir = $self->getParamValue('copyFromDir');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $relativeDir = $self->getParamValue('relativeDir');

  my $experimentDatasetName = $self->getParamValue('experimentDatasetName');

  my $fileType = $self->getParamValue('fileType');
  my $experimentType = $self->getParamValue('experimentType');

  my $gusConfigFile = $self->getParamValue('gusConfigFile');
  $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";
  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  my $organismNameForFiles =
      $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getNameForFiles();

  
  my $copyToDir = "$websiteFilesDir/$relativeDir/$organismNameForFiles/${experimentType}/${fileType}/$experimentDatasetName";

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $fileSuffix = ".${fileType}";

  if($fileType eq 'bigwig') {
    $fileSuffix = ".bw";
  }


  if($undo) {
    $self->runCmd(0, "rm -f $copyToDir/*${fileSuffix}");
    $self->runCmd(0, "rm -f $copyToDir/metadata*") if($fileType eq 'bigwig');
  } else{
    $self->runCmd($test, "mkdir -p $copyToDir");
    $self->runCmd($test, "cp $workflowDataDir/${copyFromDir}/*${fileSuffix} $copyToDir");
    $self->runCmd($test, "cp $workflowDataDir/${copyFromDir}/metadata* $copyToDir") if($fileType eq 'bigwig');;
  }

}

1;
