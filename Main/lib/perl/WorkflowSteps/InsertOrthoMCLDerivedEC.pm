package ApiCommonWorkflow::Main::WorkflowSteps::InsertOrthoMCLDerivedEC;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $evidenceCode = $self->getParamValue('evidenceCode');
  my $idSql = $self->getParamValue('idSql');

  my $args = "--ECMappingFile $inputFile --evidenceCode '$evidenceCode' --aaSeqLocusTagMappingSql '$idSql'";

  $self->testInputFile('inputFile', "$inputFile");

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertEcMappingFromOrtho", $args);

}

1; 
