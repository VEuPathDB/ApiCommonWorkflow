package ApiCommonWorkflow::Main::WorkflowSteps::AddPolyAGenes;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $gusConfigFile= "$ENV{GUS_HOME}/config/gus.config";

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "addPolyAGenes.pl --gusConfigFile $gusConfigFile --commit";
  
  if ($undo) {
      #need to remove the rows from apidb.PolyAGenes
  }else {
    $self->runCmd($test, $cmd);
  }

}

1;
