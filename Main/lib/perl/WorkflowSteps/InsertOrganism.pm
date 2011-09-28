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
  my $isDraftGenome = $self->getBooleanParamValue('isDraftGenome');
  my $hasTemporaryNcbiTaxonId = $self->getBooleanParamValue('hasTemporaryNcbiTaxonId');
  my $hasPlastidGenomeSeq = $self->getBooleanParamValue('hasPlastidGenomeSeq');
  my $hasMitoGenomeSeq = $self->getBooleanParamValue('hasMitoGenomeSeq');

  my $ag = $isAnnotatedGenome? '--isAnnotatedGenome' : '';
  my $rs = $isReferenceStrain? '--isReferenceStrain' : '';
  my $dg = $isDraftGenome? '--isDraftGenome' : '';
  my $tnt = $hasTemporaryNcbiTaxonId? '--hasTemporaryNcbiTaxonId' : '';
  my $pgs = $hasPlastidGenomeSeq? '--hasPlastidGenomeSeq' : '';
  my $mgs = $hasMitoGenomeSeq? '--hasMitoGenomeSeq' : '';

  my $args = "--fullName '$fullName' --projectName $project --ncbiTaxonId $ncbiTaxonId --speciesNcbiTaxonId $speciesNcbiTaxonId --abbrev $abbrev --abbrevPublic $abbrevPublic --nameForFilenames $nameForFilenames --abbrevOrthomcl $abbrevOrthomcl --abbrevStrain  $abbrevStrain --abbrevRefStrain  $abbrevRefStrain $ag $rs $dg $tnt $pgs $mgs";

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertOrganism", $args);

}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

