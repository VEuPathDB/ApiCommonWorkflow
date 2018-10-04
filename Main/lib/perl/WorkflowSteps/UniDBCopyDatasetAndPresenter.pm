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

  # get step properties
  my $svnDatasets = $self->getConfig('svnDatasets');
  my $svnPresenters = $self->getConfig('svnPresenters');

  unless($test) {

    if($undo) {
      $self->runCmd($test, "rm -rf $workflowDataDir/$datasetsDir/${componentProjectName}*");
      $self->runCmd($test, "rm -rf $workflowDataDir/$presentersDir/${componentProjectName}*");
    }
    else {
      $self->runCmd($test, "svn export $svnDatasets/$componentProjectName $workflowDataDir/$datasetsDir/$componentProjectName");
      $self->runCmd($test, "svn export $svnDatasets/${componentProjectName}.xml $workflowDataDir/$datasetsDir/${componentProjectName}.xml");

      $self->runCmd($test, "svn export $svnPresenters/${componentProjectName}.xml $workflowDataDir/$presentersDir/${componentProjectName}.xml");
    }
  }
}

1;

