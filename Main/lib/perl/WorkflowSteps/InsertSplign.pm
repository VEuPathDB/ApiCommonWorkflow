package ApiCommonWorkflow::Main::WorkflowSteps::InsertSplign;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $queryExtDbRlsSpec = $self->getParamValue('queryExtDbRlsSpec');

  my $subjectExtDbRlsSpec = $self->getParamValue('subjectExtDbRlsSpec');

  my $inputFile = $self->getParamValue('inputFile');

  my $queryTable = $self->getParamValue('queryTable');

  my $subjectTable = $self->getParamValue('subjectTable');

  my $args = "--inputFile $inputFile --estTable '$queryTable' --seqTable '$subjectTable' --estExtDbRlsSpec '$queryExtDbRlsSpec' --seqExtDbRlsSpec '$subjectExtDbRlsSpec'";

  my $workflowDataDir = $self->getWorkflowDataDir();

  $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");

  $self -> runPlugin ($test, $undo, "ApiCommonData::Load::Plugin::InsertSplignAlignments", $args);
}


1;
