package ApiCommonWorkflow::Main::WorkflowSteps::MakeOrganismWebsiteSubdir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

## make a directory for website files.  construct a path, and then make
## the leaf directory specified.

## do not use mkdir -p.  this step can only make one leaf dir.
## in undo mode it deletes just that dir

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $useSpeciesName = $self->getBooleanParamValue('useSpeciesName');

  # this is relative to the website files dir.
  # it will look something like downloadSite/ToxoDB/release-6.3
  my $relativeDir = $self->getParamValue('relativeDir');
  my $subDir = $self->getParamValue('subDir');

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  my $organismNameForFiles =
      $self->getOrganismInfo($test, $organismAbbrev)->getNameForFiles();

  if ($useSpeciesName) {
    $organismNameForFiles =
      $self->getOrganismInfo($test, $organismAbbrev)->getSpeciesNameForFiles();
  }

  my $dir = "$websiteFilesDir/$relativeDir/$organismNameForFiles/$subDir";

  if ($undo){
      # it should be empty because child steps remove their files
      $self->runCmd(0, "rmdir $dir");  

  } else {
      $self->runCmd(0, "mkdir $dir");
      # go to root of local path to avoid skipping intermediate dirs
      #my @path = split(/\//,$apiSiteFilesDir);
      #$self->runCmd(0, "chmod -R g+w $baseDir/$path[0]");
  }
}

sub getConfigDeclaration {
  return (
         # [name, default, description]
         );
}

