package ApiCommonWorkflow::Main::WorkflowSteps::ExtractFileAttributes;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

# Write the apidb.fileattributes rows of one release (loadFileAttributes.pl format)
# from this workflow's staging copy of the download site,
# <websiteFilesDir>/<workflow>/<version>/real/downloadSite/<Project>/release-CURRENT,
# with paths and names as they will be published under UniDB/release-<release>.
#
# The staging dir holds only the current release: undoing and rerunning this
# step for an older release after a newer one is staged reads the newer files.

sub run {
  my ($self, $test, $undo) = @_;

  my $release = $self->getParamValue('release');
  my $outputFile = $self->getWorkflowDataDir() . "/" . $self->getParamValue('outputFile');
  my $gusConfigFile = $self->getGusConfigFile();
  my $stagingDir = $self->getWebsiteFilesDir($test) . "/downloadSite";

  if ($undo) {
    $self->runCmd(0, "rm -f $outputFile");
  } else {
    # the script dies if the staging dir is missing or holds no files
    $self->runCmd($test, "extractDownloadData.pl --gusConfigFile $gusConfigFile --build_number $release --stagingDir $stagingDir > $outputFile");
    if (!$test) {
      $self->error("No download files found for release $release: '$outputFile' is empty") if -z $outputFile;
    }
  }
}

1;
