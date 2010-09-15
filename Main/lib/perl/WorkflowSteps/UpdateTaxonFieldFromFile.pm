package ApiCommonWorkflow::Main::WorkflowSteps::UpdateTaxonFieldFromFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');
  my $taxIdFile = $self->getParamValue('taxIdFile');


  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--fileName $workflowDataDir/$taxIdFile  --sourceIdRegex  '^(\\d+)' --ncbiTaxIdRegex '^\\d+\\s(\\d+)' --idSql 'select source_id, aa_sequence_id from dots.externalaasequence where taxon_id is null' --extDbRelSpec 'NRDB|2010-06-14'  --tableName 'DoTS::ExternalAASequence'";

  if ($test) {
    $self->testInputFile('fastaFile', "$workflowDataDir/$fastaFile");
    $self->testInputFile('idsFile', "$workflowDataDir/$idsFile");
  }

  $self->runPlugin($test,$undo, "ApiCommonData::Load::Plugin::UpdateTaxonFieldFromFile",$args);

}

sub getParamDeclaration {
  return (
	  'idsFile',
	  'extDbRlsSpec',
	  'fastaFile',
	 );
}


sub getConfigDeclaration {
  return ();
}


