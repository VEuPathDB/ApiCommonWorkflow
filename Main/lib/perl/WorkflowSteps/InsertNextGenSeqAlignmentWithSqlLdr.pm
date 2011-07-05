package ApiCommonWorkflow::Main::WorkflowSteps::InsertNextGenSeqAlignmentWithSqlLdr;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');

  my $extDbSpecs = $self->getParamValue('extDbSpecs');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my ($externalDatabase,$externalDatabaseRls) = split(/\|/,$extDbSpecs);

  my $args = "--dataFile $workflowDataDir/$inputFile --externalDatabase $externalDatabase --externalDatabaseRls $externalDatabaseRls";

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertNextGenSeqAlignmentWithSqlLdr", $args);

}

sub getParamDeclaration {
  return (
	  'inputFile',
	  'extDbSpecs',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

