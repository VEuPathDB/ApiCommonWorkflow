package ApiCommonWorkflow::Main::WorkflowSteps::PredictEcNumbers;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $organismDir = $workflowDataDir."/".$self->getParamValue('organismDir');

  if ($undo) {
    next;
  } else {
    my $cmd = "orthomclEcPrediction $outputDir $organismDir";
    $self->runCmd($test, $cmd);
  }
}


