package ApiCommonWorkflow::Main::WorkflowSteps::MakeDecoyDatabase;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameter values
  my $inputFile = $self->getParamValue("inputFile");
  my $outputFile = $self->getParamValue("outputFile");
  my $decoyRatio = $self->getParamValue("decoyRatio");
  my $decoyRegEx = $self->getParamValue("decoyRegEx");

  $inputFile=~s/\/+/\//g;
  $outputFile=~s/\/+/\//g;
  # expects string true/false
  
  my $workflowDataDir = $self->getWorkflowDataDir();
  my $cmd = "create_fasta_for_searchEngine.pl --inputFile $inputFile --decoyRatio $decoyRatio --decoyRegEx $decoyRegEx --outputFile $outputFile"
  
  if ($undo) {
    $self->runCmd(0, "rm -rf $workflowDataDir/$outputFile");
  }else {
      if ($test) {
	  $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
      }else {
      $self->runCmd($test, $cmd);
	  }
	}
  	
	sub getParamsDeclaration {
  return ('inputFile',
	      'outputFile',
		  'decoyRatio',
		  'decoyRegEx',
	     );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	  ["", "", ""],
	 );
}
