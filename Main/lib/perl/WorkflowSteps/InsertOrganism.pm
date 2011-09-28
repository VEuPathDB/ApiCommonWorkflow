package ApiCommonWorkflow::Main::WorkflowSteps::InsertOrganism;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $fullName = $self->getParamValue('fullName');
  my $project = $self->getParamValue('project');
  my $ncbiTaxonId = $self->getParamValue('ncbiTaxonId');
  my $speciesNcbiTaxonId = $self->getParamValue('speciesNcbiTaxonId');
  my $abbrev = $self->getParamValue('abbrev');
  my $abbrevPublic = $self->getParamValue('abbrevPublic');
  my $nameForFilenames = $self->getParamValue('nameForFilenames');
  my $abbrevOrthomcl = $self->getParamValue('abbrevOrthomcl');
  my $abbrevStrain = $self->getParamValue('abbrevStrain');
  my $abbrevRefStrain = $self->getParamValue('abbrevRefStrain');
  my $isAnnotatedGenome = $self->getParamValue('isAnnotatedGenome');
  my $isReferenceStrain = $self->getParamValue('isReferenceStrain');
  my $isDraftGenome = $self->getParamValue('isDraftGenome');
  my $hasTemporaryNcbiTaxonId = $self->getParamValue('hasTemporaryNcbiTaxonId');

  my $args = "--fullName '$fullName' --projectName $project --ncbiTaxonId $ncbiTaxonId --speciesNcbiTaxonId $speciesNcbiTaxonId --abbrev $abbrev --abbrevPublic $abbrevPublic --nameForFilenames $nameForFilenames --abbrevOrthomcl $abbrevOrthomcl --abbrevStrain  $abbrevStrain --abbrevRefStrain  $abbrevRefStrain --isAnnotatedGenome  $isAnnotatedGenome --isReferenceStrain  $isReferenceStrain --isDraftGenome $isDraftGenome --hasTemporaryNcbiTaxonId $hasTemporaryNcbiTaxonId";

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertOrganism", $args);

}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

