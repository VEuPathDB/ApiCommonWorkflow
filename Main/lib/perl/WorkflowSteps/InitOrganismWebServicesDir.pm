package ApiCommonWorkflow::Main::WorkflowSteps::InitOrganismWebServicesDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::Util::OrganismInfo;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $organismAbbrev = $self->getParamValue('organismAbbrev');

  # this is relative to the website files dir.
  # it will look something like webServices/ToxoDB/release-6.3
  my $relativeDir = $self->getParamValue('relativeDir');

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  my $fullPath = "$websiteFilesDir/$relativeDir/$organismAbbrev";
  if ($undo) {
      # should be empty because dependent steps removed their files
      $self->runCmd(0, "rmdir $fullPath");
  } else {
      # do not use -p.  previous steps should have created parent dirs
      # also, this validates that the dir doesn't already exist
      $self->runCmd(0, "mkdir $fullPath");
  }
}

sub getConfigDeclaration {
  return (
	 );
}


