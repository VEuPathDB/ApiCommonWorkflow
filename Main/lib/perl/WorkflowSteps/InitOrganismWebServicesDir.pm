package ApiCommonWorkflow::Main::WorkflowSteps::InitOrganismWebServicesDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::Util::OrganismInfo;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $useSpeciesName = $self->getBooleanParamValue('useSpeciesName');

  # this is relative to the website files dir.
  # it will look something like webServices/ToxoDB/release-6.3
  my $relativeDir = $self->getParamValue('relativeDir');

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  my $organismNameForFiles = $useSpeciesName?
      $self->getOrganismInfo($test, $organismAbbrev)->getSpeciesNameForFiles() :
      $self->getOrganismInfo($test, $organismAbbrev)->getNameForFiles();

  my $fullPath = "$websiteFilesDir/$relativeDir/$organismNameForFiles";
  if ($undo) {
      $self->runCmd(0, "rm -rf $fullPath");
  } else {
      $self->runCmd(0, "mkdir -p $fullPath");
  }
}

sub getParamsDeclaration {
    return (
	'organismAbbrev',
	'relativeDir',
	);
}

sub getConfigDeclaration {
  return (
	 );
}


