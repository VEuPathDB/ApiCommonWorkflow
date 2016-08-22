package ApiCommonWorkflow::Main::WorkflowSteps::ExtractIdsFromBlastResult;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $idType = $self->getParamValue('idType');
  my $outputFile = $self->getParamValue('outputFile');

  # HACK: see if a filtered version of the inputFile exists, and use it if so
  $inputFile = "${inputFile}.filtered" if -e "${inputFile}.filtered";

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $cmd = "makeIdFileFromBlastSimOutput --$idType --subject --blastSimFile $workflowDataDir/$inputFile --outFile $workflowDataDir/$outputFile";

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {
    $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
      if ($test) {
	  $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
      }
    $self->runCmd($test,$cmd);
  }
}

1;
