package ApiCommonWorkflow::Main::WorkflowSteps::InsertOrthoMCLDerivedEC;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $evidenceCode = $self->getParamValue('evidenceCode');
  my $idSql = $self->getParamValue('idSql');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--ECMappingFile $workflowDataDir/$inputFile --evidenceCode '$evidenceCode' --aaSeqLocusTagMappingSql '$idSql'";

  $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");

  $self->runPlugin($test, $undo, "GUS::Community::Plugin::InsertECMapping", $args);

}

1; 
