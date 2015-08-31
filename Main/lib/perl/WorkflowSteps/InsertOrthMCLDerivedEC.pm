package ApiCommonWorkflow::Main::WorkflowSteps::InsertOrthMCLDerivedEC;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $evidenceCode = $self->getParamValue('evidenceCode');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = qq(--ECMappingFile $workflowDataDir/$inputFile --evidenceCode $evidenceCode --aaSeqLocusTagMappingSql "select taf.aa_sequence_id from dots.Transcript t, dots.TranslatedAAFeature taf, dots.GeneFeature gf where gf.source_id = ? and gf.na_feature_id = t.parent_id and t.na_feature_id = taf.na_feature_id);

  $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");

  $self->runPlugin($test, $undo, "GUS::Community::Plugin::InsertECMapping", $args);

}

1; 
