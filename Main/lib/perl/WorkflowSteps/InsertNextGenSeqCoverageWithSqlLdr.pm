package ApiCommonWorkflow::Main::WorkflowSteps::InsertNextGenSeqCoverageWithSqlLdr;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');

  my $isReversed = $self->getBooleanParamValue('isReversed');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--dataFile $workflowDataDir/$inputFile --isReversed $isReversed";

  if ($test) {
      $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
      $self->runCmd(0,"echo test > $workflowDataDir/$inputFile.ctrl") unless $undo;
  }

  if ($undo) {
      $self->runCmd(0, "rm $workflowDataDir/$inputFile.ctrl");
  }

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertNextGenSeqCoverageWithSqlLdr", $args);

}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

