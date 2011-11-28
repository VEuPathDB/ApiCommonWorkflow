package ApiCommonWorkflow::Main::WorkflowSteps::ParseVarscanToGff;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');

  my $outputFile =  $self->getParamValue('outputFile');

  my $strain = $self->getParamValue('strain');

  my $percentCutoff = $self->getParamValue('percentCutoff');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "parseVarscanToGFF.pl --f $workflowDataDir/$inputFile --strain '$strain' --pc $percentCutoff --o $workflowDataDir/$outputFile";
  
  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  }else {
      if ($test){
	  $self->runCmd(0, "echo test > $workflowDataDir/$outputFile");
      }else{
	    $self->runCmd($test, $cmd);
      }
  }

}

sub getParamDeclaration {
  return (
	  'inputFile',
	  'outputFile',
	  'strain',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

