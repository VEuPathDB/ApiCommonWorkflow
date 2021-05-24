package ApiCommonWorkflow::Main::WorkflowSteps::CopyNrProteinToGenomicGffFileToWebServices;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;

sub run {
  my ($self, $test, $undo) = @_;

  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $resultsDir = $self->getParamValue('resultsDir');
  my $webServicesRelativeDir = $self->getParamValue('relativeWebServicesDir');

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  my $organismNameForFiles = $self->getOrganismInfo($test, $organismAbbrev)->getNameForFiles();

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $fullResultsDir = "$workflowDataDir/$resultsDir";

  my $copyToDir = "$websiteFilesDir/$webServicesRelativeDir/$organismNameForFiles/nrProteinsToGenomeAlign/";


  if($undo) {
    $self->runCmd(0, "rm -f $copyToDir/*.gz*");
  } else{
      if($test){
	  $self->runCmd(0, "echo test > $copyToDir/result.gff.gz ");
	  $self->runCmd(0, "echo test > $copyToDir/result.gff.gz.tbi");
      }
    $self->runCmd($test, "mkdir -p $copyToDir");
    $self->runCmd($test, "cp $fullResultsDir/*.gz* $copyToDir/");
  }
}

1;


