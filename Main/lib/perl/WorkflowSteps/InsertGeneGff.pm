package ApiCommonWorkflow::Main::WorkflowSteps::InsertGeneGff;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;

sub run {
  my ($self, $test, $undo) = @_;

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);
  my $relativeDir = $self->getParamValue('relativeDir');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $gusConfigFile = $self->getParamValue('gusConfigFile');
  $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";

  my $organismNameForFiles = $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getNameForFiles();
  my $speciesNameForFiles = $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getSpeciesNameForFiles();
  my $isSpeciesLevel = $self->getIsSpeciesLevel();
  my $familyNameForFiles = $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getFamilyNameForFiles();
  my $isFamilyLevel = $self->getIsFamilyLevel();
  my $projectName = $self->getParamValue('projectName');
  my $projectVersion = $self->getParamValue('projectVersionForWebsiteFiles');
  my $fileType = $self->getParamValue('fileType');
  my $dataName = $self->getParamValue('dataName');

  my $gffFile = ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker::getDownloadFileName($websiteFilesDir, $relativeDir, $organismNameForFiles, $speciesNameForFiles, $isSpeciesLevel, $familyNameForFiles, $isFamilyLevel, $projectName, $projectVersion, $fileType, $dataName);

  my $args = "--gffFile $gffFile --projectName $projectName";

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertGeneGff", $args);
}

sub getIsSpeciesLevel {
    return 0;
}

sub getIsFamilyLevel {
    return 0;
}

1;
