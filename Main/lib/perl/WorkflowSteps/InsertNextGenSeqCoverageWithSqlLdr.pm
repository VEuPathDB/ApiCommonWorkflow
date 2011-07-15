package ApiCommonWorkflow::Main::WorkflowSteps::InsertNextGenSeqCoverageWithSqlLdr;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');

  my $isReversed = $self->getParamValue('isReversed');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--dataFile $workflowDataDir/$inputFile";

  if ($isReversed eq "yes"){

      $args .= " --isReversed 1";

  }else{

      $args .= " --isReversed 0";
  }

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertNextGenSeqCoverageWithSqlLdr", $args);

}

sub getParamDeclaration {
  return (
	  'inputFile',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

