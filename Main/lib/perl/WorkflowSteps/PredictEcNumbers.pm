package ApiCommonWorkflow::Main::WorkflowSteps::PredictEcNumbers;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $organismDir = $workflowDataDir."/".$self->getParamValue('organismDir');
  my $outputDir  = $self->getParamValue('outputDir');
  my $outputFile  = $workflowDataDir."/".$self->getParamValue('outputFile');
  my $gusConfigFile = $workflowDataDir . "/" . $self->getParamValue('gusConfigFile');

  if ($undo) {
    my $cmd = "rm $outputFile";
    $self->runCmd($test, $cmd);
  } else {
    my $cmd = "orthomclEcPrediction $outputDir $organismDir $outputFile $gusConfigFile";
    $self->runCmd($test, $cmd);
  }
}


