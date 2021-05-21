package ApiCommonWorkflow::Main::WorkflowSteps::CopyNrdbBlatGffFileToWebServices;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;

sub run {
  my ($self, $test, $undo) = @_;

  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $nrdbBlatGff=$self->getParamValue('nrdbBlatGff');
  my $webServicesRelativeDir = $self->getParamValue('relativeWebServicesDir');

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  my $organismNameForFiles = $self->getOrganismInfo($test, $organismAbbrev)->getNameForFiles();

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $copyToDir = "$websiteFilesDir/$webServicesRelativeDir/$organismNameForFiles/blat/";


  if($undo) {
    $self->runCmd(0, "rm -f $copyToDir/$nrdbBlatGff.gz");
    $self->runCmd(0, "rm -f $copyToDir/$nrdbBlatGff.gz.tbi");
  } else{
      if($test){
	  $self->runCmd(0, "echo test > $copyToDir/$nrdbBlatGff.gff.gz ");
	  $self->runCmd(0, "echo test > $copyToDir/$nrdbBlatGff.gff.gz.tbi");
      }
    $self->runCmd($test, "cp $workflowDataDir/$nrdbBlatGff.gz $copyToDir");
    $self->runCmd($test, "cp $workflowDataDir/$nrdbBlatGff.gz.tbi $copyToDir");
  }
}

1;
