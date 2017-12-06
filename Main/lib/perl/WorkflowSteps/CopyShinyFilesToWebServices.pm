package ApiCommonWorkflow::Main::WorkflowSteps::CopyShinyFilesToWebServices;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $datasetName = $self->getParamValue('datasetName');
  my $inputFileBaseName = $self->getParamValue('inputFileBaseName');
  my $webServicesRelativeDir = $self->getParamValue('relativeWebServicesDir');

  # standard parameters for making download files
  my $websiteFilesDir = $self->getWebsiteFilesDir($test);
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $copyToDir = "$websiteFilesDir/$webServicesRelativeDir/$datasetName/shiny";

  if($undo) {
    $self->runCmd(0, "rm -f $copyToDir/*");
  } else{
      if($test){
	  $self->runCmd(0, "mkdir -p $copyToDir");
      }
    $self->runCmd($test, "mkdir -p $copyToDir");
    $self->runCmd($test, "cp $workflowDataDir/$datasetName/$inputFileBaseName* $copyToDir");
  }
}

1;
