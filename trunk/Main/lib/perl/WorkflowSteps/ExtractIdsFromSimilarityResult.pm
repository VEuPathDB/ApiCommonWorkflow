package ApiCommonWorkflow::Main::WorkflowSteps::ExtractIdsFromSimilarityResult;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $inputFileType = $self->getParamValue('inputFileType');
  my $idType = $self->getParamValue('idType');
  my $outputFile = $self->getParamValue('outputFile');

  $self->error("Parameter inputFileType=$inputFileType is invalid.  It must be either blat or blast") unless $inputFileType eq 'blat' || $inputFileType eq 'blastSim';

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $cmd;
  if ($inputFileType eq 'blastSim') {
      $cmd = "makeIdFileFromBlastSimOutput --$idType --subject --blastSimFile $workflowDataDir/$inputFile --outFile $workflowDataDir/$outputFile";
  } else {
      $cmd = "makeIdFileFromBlatOutput --blatFile $workflowDataDir/$inputFile --outFile $workflowDataDir/$outputFile --query";
  }

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

