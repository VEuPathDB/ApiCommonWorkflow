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

  my $unidbWebsiteBranch = $self->getSharedConfig("unidbWebsiteBranch");

  my $componentProps = $self->getSharedConfig($componentProjectName . "_PROPS");
  my $componentPropsHash = eval $componentProps;
  $self->error("error in PROPS object in stepsShared.prop for $componentProjectName") if($@);
  my $datasetsBranch = $componentPropsHash->{datasetsBranch};
  my $presentersBranch = $componentPropsHash->{presentersBranch};
  unless($datasetsBranch && $presentersBranch) {
    $self->error("datasetsBranch and presentersBranch must be specified in PROPS object in stepsShared.prop for $componentProjectName");
  }

  unless($test) {
    if($undo) {
      $self->runCmd($test, "rm -rf $workflowDataDir/git/$componentProjectName");
    }
    else {
      $self->runCmd($test, "mkdir -p $workflowDataDir/git/$componentProjectName");
      chdir "$workflowDataDir/git/$componentProjectName";
      $self->runCmd($test, "unidbSnapshotDatasetsAndPresenters.bash -d $datasetsBranch -p $presentersBranch -t $unidbWebsiteBranch -c $componentProjectName");
    }
  }
}

1;

