package ApiCommonWorkflow::Main::WorkflowSteps::MakePathwayDownloadFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $gusConfigFile= "$ENV{GUS_HOME}/config/gus.config";
  my $relativePathwayDownloadSiteDir =  $self->getParamValue('relativePathwayDownloadSiteDir');
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "makePathwayImgDataFiles.pl --gusConfigFile $gusConfigFile -- outputDir relativePathwayDownloadSiteDir --pathwayList ALL --commit";

  if ($undo) {
      #need to remove the rows from apidb.PolyAGenes
  }else {
      if ($test){
      }else{
	    $self->runCmd($test, $cmd);
      }
  }

}

sub getParamDeclaration {
  return (
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

