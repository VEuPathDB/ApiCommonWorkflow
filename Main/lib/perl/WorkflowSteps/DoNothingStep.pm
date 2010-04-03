package ApiCommonWorkflow::Main::WorkflowSteps::DoNothingStep;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;
}

sub getParamsDeclaration {
  return ('',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}



