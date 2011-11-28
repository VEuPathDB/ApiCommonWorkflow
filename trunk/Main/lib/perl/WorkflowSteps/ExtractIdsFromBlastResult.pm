package ApiCommonWorkflow::Main::WorkflowSteps::ExtractIdsFromBlastResult;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $idType = $self->getParamValue('idType');
  my $outputFile = $self->getParamValue('outputFile');

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $cmd = "makeIdFileFromBlastSimOutput --$idType --subject --blastSimFile $workflowDataDir/$inputFile --outFile $workflowDataDir/$outputFile";

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {
      if ($test) {
	  $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
	  $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
      }else{
	  $self->runCmd($test,$cmd);
      }
  }

}

sub getParamsDeclaration {
  return (
	  'idType',
	  'outputFile',
	  'inputFile',
	 );
}

sub getConfigDeclaration {
  return
    (
    );
}

