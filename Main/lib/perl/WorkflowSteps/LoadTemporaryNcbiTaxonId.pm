package ApiCommonWorkflow::Main::WorkflowSteps::LoadTemporaryNcbiTaxonId;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $organismFullName = $self->getParamValue('organismFullName');
  my $ncbiTaxonId = $self->getParamValue('ncbiTaxonId');
  my $speciesNcbiTaxonId = $self->getParamValue('speciesNcbiTaxonId');

   # validate temp ncbi taxon id
  if ($ncbiTaxonId < 9000000000) {
      $self->error("hasTemporaryNcbiTaxonId is true but the provided ncbi taxon ID does not look like a temporary one.  (It must be greater than 9000000000 to be a temp ID)");
  }

  my ($parentRank, $geneticCodeId, $mitochondrialGeneticCodeId) = $self->getParentInfoFromSpeciesNcbiTaxId($test,$speciesNcbiTaxonId);
 
  my $args = "--parentNcbiTaxId $speciesNcbiTaxonId --parentRank $parentRank --ncbiTaxId $ncbiTaxonId --rank 'no rank' --name '$organismFullName' --nameClass 'scientific name' --geneticCodeId $geneticCodeId --mitochondrialGeneticCodeId $mitochondrialGeneticCodeId";

  $self->runPlugin($test, $undo, "GUS::Supported::Plugin::InsertTaxonAndTaxonName", $args);

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}
}

