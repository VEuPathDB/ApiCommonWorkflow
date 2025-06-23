package ApiCommonWorkflow::Main::WorkflowSteps::CopyVCFToWebServiceDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::Util::OrganismInfo;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $vcfFile = $self->getParamValue('vcfFile');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $relativeDir = $self->getParamValue('relativeDir');

  my $experimentDatasetName = $self->getParamValue('experimentDatasetName');

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);
  my $gusConfigFile = $self->getParamValue('gusConfigFile');
  $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";

  my $organismNameForFiles =
      $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getNameForFiles();

  my $copyToDir = "$websiteFilesDir/$relativeDir/$organismNameForFiles/prealigned/vcf/$experimentDatasetName";

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd_mkdir = "mkdir -p $copyToDir";

  my $cmd_copy = "cp $workflowDataDir/$vcfFile $copyToDir"; 


  if ($undo) {
    $self->runCmd(0, "rm -fr $copyToDir");
  } else {
    $self->testInputFile('vcfFile', "$workflowDataDir/$vcfFile");
    $self->runCmd($test, $cmd_mkdir);
    $self->runCmd($test, $cmd_copy);
    $self->runCmd($test, "cp $workflowDataDir/$vcfFile.tbi $copyToDir");  
}

}

1;


