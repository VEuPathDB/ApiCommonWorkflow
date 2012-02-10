package ApiCommonWorkflow::Main::WorkflowSteps::ValidateOrganismInfo;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $strainAbbrev = $self->getParamValue('strainAbbrev');
  my $projectName = $self->getParamValue('projectName');
  my $ncbiTaxonId = $self->getParamValue('ncbiTaxonId');
  my $speciesNcbiTaxonId = $self->getParamValue('speciesNcbiTaxonId');

  my $orgInfo = $self->getOrganismInfo($test, $organismAbbrev);

  if (!$test) {
      $db = $orgInfo->getStrainAbbrev();
      $self->error("strainAbbrev '$strainAbbrev' does not match the value in the database: '$db'") unless $strainAbbrev eq $db;

      $db = $orgInfo->getNcbiTaxonId();
      $self->error("ncbiTaxonId '$ncbiTaxonId' does not match the value in the database: '$db'") unless $ncbiTaxonId eq $db;

      $db = $orgInfo->getSpeciesNcbiTaxonId();
      $self->error("speciesNcbiTaxonId '$speciesNcbiTaxonId' does not match the value in the database: '$db'") unless $speciesNcbiTaxonId eq $db;
  }
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

