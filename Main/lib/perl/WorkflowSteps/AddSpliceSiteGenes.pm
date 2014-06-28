package ApiCommonWorkflow::Main::WorkflowSteps::AddSpliceSiteGenes;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $gusConfigFile= "$ENV{GUS_HOME}/config/gus.config";

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "addSpliceSiteGenes.pl --gusConfigFile $gusConfigFile --commit";
  
  if ($undo) {
      #need to remove the rows from apidb.SpliceSiteGenes
  }else {
    $self->runCmd($test, $cmd);
  }

}

1;
