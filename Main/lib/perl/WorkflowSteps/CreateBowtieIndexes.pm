package ApiCommonWorkflow::Main::WorkflowSteps::CreateBowtieIndexes;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');

  my $outputIndexDir = $self->getParamValue('outputIndexDir');

  my $workflowDataDir = $self->getWorkflowDataDir();

  $self->runCmd(0,"mkdir -p $workflowDataDir/$outputIndexDir");
      
  if($undo){

      $self->runCmd(0,"rm -fr $workflowDataDir/$outputIndexDir");

  }else{
      if ($test) {
	  $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
      }else{
	  $self->runCmd($test, "createBowtieIndexes --inputFile $workflowDataDir/$inputFile --outputIndexDir $workflowDataDir/$outputIndexDir");
      }
  }
}

sub getParamDeclaration {
  return (
	  'inputFile',
	  'outputIndexDir',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

