package ApiCommonWorkflow::Main::WorkflowSteps::CopyResourcesFileDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $resourcesFileDir = $self->getParamValue('resourcesFileDir');
  my $toDir = $self->getParamValue('toDir');

  # get global properties
  my $downloadDir = $self->getSharedConfig('downloadDir');

  my $workflowDataDir = $self->getWorkflowDataDir();

  $self->runCmd(0,"mkdir -p $toDir") if $toDir;
  
  unless (-e $resourcesFileDir) { die "$resourcesFileDir doesn't exist\n";};

  if ($undo) {
    $self->runCmd(0, "rm -rf $toDir");
  } else {
    $self->runCmd(0, "cp -ar  $resourcesFileDir $toDir");
  }

}

1;
