package ApiCommonWorkflow::Main::WorkflowSteps::CopyCellxgeneToWebServices;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;

sub run {
  my ($self, $test, $undo) = @_;

  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $h5adFile = $self->getParamValue('h5adFile');
  my $webServicesRelativeDir = $self->getParamValue('relativeWebServicesDir');
  my $datasetName = $self->getParamValue('datasetName');

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $fromFile = "$workflowDataDir/$h5adFile";

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);
  my $copyToDir = "$websiteFilesDir/$webServicesRelativeDir/cellxgene";
  my $copyToFile = "$copyToDir/$datasetName.h5ad";


  if($undo) {
    $self->runCmd(0, "rm -f $copyToFile");
  } else{
      if($test){
          $self->runCmd(0, "echo test > $copyToFile ");
      }
    $self->runCmd($test, "mkdir -p $copyToDir");
    $self->runCmd($test, "cp $fromFile $copyToFile");
  }
}

1;
