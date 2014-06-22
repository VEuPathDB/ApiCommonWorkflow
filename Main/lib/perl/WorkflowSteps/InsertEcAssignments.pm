package ApiCommonWorkflow::Main::WorkflowSteps::InsertEcAssignments;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $inputEcMappingFile = $self->getParamValue('inputEcMappingFile');
  my $evidence = $self->getParamValue('evidence');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--ECMappingFile orthomcl.ec --evidenceCode $evidence --aaSeqLocusTagMappingSql 'select aa_sequence_id from dots.ExternalAaSequence where secondary_identifier = ?'";

  $self->testInputFile('inputEcMappingFile', "$workflowDataDir/$inputEcMappingFile");

  $self->runPlugin($test, $undo, "GUS::Community::Plugin::InsertECMapping", $args);
}

