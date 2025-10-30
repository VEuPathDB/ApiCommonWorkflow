package ApiCommonWorkflow::Main::WorkflowSteps::CheckForFungiOrganism;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $projectName = $self->getParamValue("projectName");
  my $taxonId = $self->getParamValue("taxonId");
  my $skipIfFile = join("/", $workflowDataDir, $self->getParamValue("skipIfFile"));
  my $gusConfigFileFile = join("/", $workflowDataDir, $self->getParamValue("gusConfigFile"));

  my $cmd = "checkForFungiOrganism.pl $projectName $taxonId $skipIfFile $gusConfigFile";

  if ($undo){
    if (-e $skipIfFile) {
      $self->runCmd(0, "rm $skipIfFile");
    }
  }
  else {
      $self->runCmd($test, $cmd);
  }

}


1;
