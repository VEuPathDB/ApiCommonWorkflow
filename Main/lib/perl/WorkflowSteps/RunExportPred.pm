package ApiCommonWorkflow::Main::WorkflowSteps::RunExportPred;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $proteinsFile = $self->getParamValue('proteinsFile');
  my $outputFile = $self->getParamValue('outputFile');

  my $binPath = $self->getConfig('binPath');

  my $workflowDataDir = $self->getWorkflowDataDir();


  my $cmd = "${binPath}/exportpred --input=$workflowDataDir/$proteinsFile --output=$workflowDataDir/$outputFile";

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {
    $self->testInputFile('proteinsFile', "$workflowDataDir/$proteinsFile");
      if ($test) {
	  $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
      }
    $self->error("Proteins file '$proteinsFile' does not exist or is empty") unless -s "$workflowDataDir/$proteinsFile";  # in case exportpred does not test
    $self->runCmd($test,$cmd);
  }
}


1;
