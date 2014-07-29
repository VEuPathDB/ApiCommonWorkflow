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
  my $useFamilyName = $self->getBooleanParamValue('useFamilyName');

  # this is relative to the website files dir.
  # it will look something like downloadSite/ToxoDB/release-6.3
  my $relativeDir = $self->getParamValue('relativeDir');
  my $subDir = $self->getParamValue('subDir');
  my $needsDataSubDir = $self->getBooleanParamValue('needsDataSubDir');

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  $self->error("Parameters useFamilyName and useSpeciesName cannot both be 'true'") if $useFamilyName && $useSpeciesName;
  my $nameForFiles =
      $self->getOrganismInfo($test, $organismAbbrev)->getNameForFiles();

  if ($useSpeciesName) {
    $nameForFiles =
      $self->getOrganismInfo($test, $organismAbbrev)->getSpeciesNameForFiles();
  }
  if ($useFamilyName) {
    $nameForFiles =
      $self->getOrganismInfo($test, $organismAbbrev)->getFamilyNameForFiles();
  }

  my $dir = "$websiteFilesDir/$relativeDir/$nameForFiles/$subDir";

  if ($undo){
      # it should be empty because child steps remove their files
      $self->runCmd(0, "rmdir $dir/data") if $needsDataSubDir;  
      $self->runCmd(0, "rmdir $dir");  

  } else {
      $self->runCmd(0, "mkdir $dir");
      $self->runCmd(0, "mkdir $dir/data") if $needsDataSubDir;
      # go to root of local path to avoid skipping intermediate dirs
      #my @path = split(/\//,$apiSiteFilesDir);
      #$self->runCmd(0, "chmod -R g+w $baseDir/$path[0]");
  }
}

1;
