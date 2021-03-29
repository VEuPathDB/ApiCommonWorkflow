package ApiCommonWorkflow::Main::WorkflowSteps::UniDBCopyDatasetAndPresenter;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use Cwd qw(getcwd);

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
      # $self->runCmd($test, "rm -rf $workflowDataDir/$datasetsDir/${componentProjectName}*");
      # $self->runCmd($test, "rm -rf $workflowDataDir/$presentersDir/${componentProjectName}*");
    }
    else {
      $self->runCmd($test, "mkdir -p $workflowDataDir/git/$componentProjectName");
      chdir "$workflowDataDir/git/$componentProjectName";
      $self->runCmd($test, "git clone git@github.com:EuPathDB/ApiCommonDatasets.git");
      chdir "ApiCommonDatasets";
      $self->runCmd($test, "git checkout unidb_website");
      $self->runCmd($test, "git checkout ebibrc4 Datasets/lib/xml/datasets/${componentProjectName}*");
      $self->runCmd($test, "git push");
    }
  }
}

1;

