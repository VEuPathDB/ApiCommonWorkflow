package ApiCommonWorkflow::Main::WorkflowSteps::InsertNextGenSeqCoverageWithSqlLdr;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--dataFile $workflowDataDir/$inputFile";

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

