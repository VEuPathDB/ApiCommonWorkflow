package ApiCommonWorkflow::Main::WorkflowSteps::UniDBCopyDatasetAndPresenter;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;

use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $componentProjectName = $self->getParamValue('componentProjectName');
  my $datasetsDir = $self->getParamValue('datasetsDir');
  my $presentersDir = $self->getParamValue('presentersDir');

  # TODO:  add to config??
  my $svnDatasets = "https://cbilsvn.pmacs.upenn.edu/svn/apidb/ApiCommonDatasets/trunk/Datasets/lib/xml/datasets";
  my $svnPresenters = "https://cbilsvn.pmacs.upenn.edu/svn/apidb/ApiCommonPresenters/trunk/Model/lib/xml/datasetPresenters";

  unless($test) {

    if($undo) {
      $self->runCmd($test, "rm -rf $workflowDataDir/$datasetsDir/${componentProjectName}*");
      $self->runCmd($test, "rm -rf $workflowDataDir/$presentersDir/${componentProjectName}*");
    }
    else {
      $self->runCmd($test, "svn export $svnDatasets/$componentProjectName $workflowDataDir/$datasetsDir");
      $self->runCmd($test, "svn export $svnDatasets/${componentProjectName}.xml $workflowDataDir/$datasetsDir");

      $self->runCmd($test, "svn export $svnPresenters/${componentProjectName}.xml $workflowDataDir/$presentersDir");
    }
  }
}

1;

