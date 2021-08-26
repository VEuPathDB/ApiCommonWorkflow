package ApiCommonWorkflow::Main::WorkflowSteps::UniDBLoadSNPs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $projectName = $self->getParamValue('projectName');
  my $loaderLogDir = $self->getParamValue('loaderLogDir');
  my $workflowVersion = $self->getParamValue('componentWorkflowVersion');

  my $componentProps = $self->getSharedConfig($projectName . "_PROPS");
  my $componentPropsHash = eval $componentProps;
  $self->error("error in PROPS object in stepsShared.prop for $projectName") if($@);
  my $databaseInstance = $componentPropsHash->{instance};
  unless($databaseInstance) {
    $self->error("instance must be specified in PROPS object in stepsShared.prop for $projectName");
  }

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $command = "mapSnpAndSeqVarForUniDB.pl --project_name $projectName --workflow_version $workflowVersion --loader_dir $workflowDataDir/$loaderLogDir --database_orig $databaseInstance";

  if ($undo) {
    $self->runCmd($test, "rm $workflowDataDir/$loaderLogDir/*");
  } else {
    unless ($test) {
      $self->runCmd($test, $command);
    }
  }



}

1;

