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
  my $abbrevPublic = $self->getParamValue('publicAbbrev');
  my $nameForFilenames = $self->getParamValue('nameForFilenames');
  my $abbrevOrthomcl = $self->getParamValue('orthomclAbbrev');
  my $abbrevStrain = $self->getParamValue('strainAbbrev');
  my $abbrevRefStrain = $self->getParamValue('refStrainAbbrev');
  my $isAnnotatedGenome = $self->getBooleanParamValue('isAnnotatedGenome');
  my $isReferenceStrain = $self->getBooleanParamValue('isReferenceStrain');
  my $hasTemporaryNcbiTaxonId = $self->getBooleanParamValue('hasTemporaryNcbiTaxonId');
  my $genomeSource = $self->getParamValue('genomeSource');
  my $isFamilyRepresentative = $self->getParamValue('isFamilyRepresentative');
  my $familyRepOrganismAbbrev = $self->getParamValue('familyRepOrganismAbbrev');
  my $familyNcbiTaxonIds = $self->getParamValue('familyNcbiTaxonIds');
  my $familyNameForFiles = $self->getParamValue('familyNameForFiles');

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

  my $fnti = "";
  my $fnff = "";
  # validate family rep stuff
  if ($isFamilyRepresentative) {
      $self->error("Parameter isFamilyRepresentative is 'true'.  Parameter familyNcbiTaxonIds must not be empty") unless $familyNcbiTaxonIds;
      $self->error("Parameter isFamilyRepresentative is 'true'.  Parameter familyNameForFiles must not be empty") unless $familyNameForFiles;
      $self->error("Parameter isFamilyRepresentative is 'true'.  Parameter familyRepOrganismAbbrev must be the same as property organismAbbrev") unless $familyRepOrganismAbbrev eq $abbrev;
      $fnti = " --familyNcbiTaxonIds '$familyNcbiTaxonIds";
      $fnff = " --familyNameForFiles $familyNameForFiles";
      
      my @ids = split(/,\s*/, $familyNcbiTaxonIds);
      $self->error("Parameter familNcbiTaxonIds must be a comma delimited list of NCBI taxon IDs") unless grep(/^\d+$/, @ids) == scalar(@ids);
      
  } else {
      $self->error("Parameter isFamilyRepresentative is 'false'.  Parameter familyNcbiTaxonIds must be empty") if $familyNcbiTaxonIds;
      $self->error("Parameter isFamilyRepresentative is 'false'.  Parameter familyNameForFiles must be empty") if $familyNameForFiles;
      $self->error("Parameter isFamilyRepresentative is 'false'.  Parameter familyRepOrganismAbbrev must not be the same as property organismAbbrev") if $familyRepOrganismAbbrev eq $abbrev;
  }

  my $args = "--fullName '$fullName' --projectName $project --ncbiTaxonId $ncbiTaxonId --speciesNcbiTaxonId $speciesNcbiTaxonId --abbrev $abbrev --publicAbbrev $abbrevPublic --nameForFilenames $nameForFilenames --genomeSource $genomeSource --orthomclAbbrev $abbrevOrthomcl --strainAbbrev  $abbrevStrain --refStrainAbbrev  $abbrevRefStrain $ag $rs $tnt $fnti $fnff";

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertOrganism", $args);

}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

