package ApiCommonWorkflow::Main::WorkflowSteps::MakeSamHeader;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $ncbiTaxonId = $self->getParamValue('ncbiTaxonId');
  my $outputFile = $self->getParamValue('outputFile');


  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {
      if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
      }else{
	    $self->runCmd($test,"createSamHeader --outputFile $workflowDataDir/$outputFile --ncbiTaxonId $ncbiTaxonId");
      }
  }
}

sub getParamsDeclaration {
  return (
	  'ncbiTaxonId',
	  'outputFile',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


