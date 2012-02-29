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
  my $isAnnotatedGenome = $self->getBooleanParamValue('isAnnotatedGenome');
  my $isReferenceStrain = $self->getBooleanParamValue('isReferenceStrain');
  my $hasTemporaryNcbiTaxonId = $self->getBooleanParamValue('hasTemporaryNcbiTaxonId');
  my $genomeSource = $self->getParamValue('genomeSource');

  my $ag = $isAnnotatedGenome? '--isAnnotatedGenome' : '';
  my $rs = $isReferenceStrain? '--isReferenceStrain' : '';
  my $tnt = $hasTemporaryNcbiTaxonId? '--hasTemporaryNcbiTaxonId' : '';

  # validate temp ncbi taxon id
  if ($hasTemporaryNcbiTaxonId && $ncbiTaxonId < 9000000000) {
      $self->error("hasTemporaryNcbiTaxonId is true but the provided ncbi taxon ID does not look like a temporary one.  (It must be greater than 9000000000 to be a temp ID)");
  }
  if (!$hasTemporaryNcbiTaxonId && $ncbiTaxonId >= 9000000000) {
      $self->error("hasTemporaryNcbiTaxonId is false but the provided ncbi taxon ID looks like a temporary one.  (It must be greater than 9000000000 to be a temp ID)");
  }

  my $args = "--fullName '$fullName' --projectName $project --ncbiTaxonId $ncbiTaxonId --speciesNcbiTaxonId $speciesNcbiTaxonId --abbrev $abbrev --abbrevPublic $abbrevPublic --nameForFilenames $nameForFilenames --genomeSource $genomeSource --abbrevOrthomcl $abbrevOrthomcl --abbrevStrain  $abbrevStrain --abbrevRefStrain  $abbrevRefStrain $ag $rs $tnt";

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertOrganism", $args);

}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

