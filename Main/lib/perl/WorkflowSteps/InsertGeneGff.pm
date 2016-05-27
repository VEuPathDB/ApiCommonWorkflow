package ApiCommonWorkflow::Main::WorkflowSteps::InsertGeneGff;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);
  my $relativeDir = $self->getParamValue('relativeDir');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $organismNameForFiles = $self->getOrganismInfo($test, $organismAbbrev)->getNameForFiles();
  my $speciesNameForFiles = $self->getOrganismInfo($test, $organismAbbrev)->getSpeciesNameForFiles();
  my $isSpeciesLevel = $self->getIsSpeciesLevel();
  my $familyNameForFiles = $self->getOrganismInfo($test, $organismAbbrev)->getFamilyNameForFiles();
  my $isFamilyLevel = $self->getIsFamilyLevel();
  my $projectName = $self->getParamValue('projectName');
  my $projectVersion = $self->getParamValue('projectVersionForWebsiteFiles');
  my $fileType = $self->getParamValue('fileType');
  my $dataName = $self->getParamValue('dataName');

  my $gffFile = getDownloadFileName($websiteFilesDir, $relativeDir, $organismNameForFiles, $speciesNameForFiles, $isSpeciesLevel, $familyNameForFiles, $isFamilyLevel, $projectName, $projectVersion, $fileType, $dataName);

  my $args = "--gffFile $gffFile --projectName $projectName";

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin:InsertGeneGff:", $args);
}

sub getIsSpeciesLevel {
    return 0;
}

1;
