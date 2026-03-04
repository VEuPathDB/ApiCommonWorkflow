package ApiCommonWorkflow::Main::WorkflowSteps::PredictEcNumbers;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $outputFile    = $workflowDataDir . "/" . $self->getParamValue('outputFile');
  my $gusConfigFile = $workflowDataDir . "/" . $self->getParamValue('gusConfigFile');
  my $threshold     = 0.4;

  if ($undo) {
    my $cmd = "rm -f $outputFile";
    $self->runCmd($test, $cmd);
  } else {
    my $cmd = "assignEcByOrthologs.pl --output $outputFile --gusConfigFile $gusConfigFile --threshold $threshold";
    $self->runCmd($test, $cmd);
  }
}


