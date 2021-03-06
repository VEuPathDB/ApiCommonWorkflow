package ApiCommonWorkflow::Main::WorkflowSteps::InitSiteDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  # this is relative to the website files dir.
  # it will look something like webServices/ToxoDB/release-6.3
  my $relativeDir = $self->getParamValue('relativeDir');

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  my $fullPath = "$websiteFilesDir/$relativeDir";
  if ($undo) {
      # should be empty because dependent steps removed their files
      $self->runCmd(0, "rmdir $fullPath");
  } else {
      # should not exist already
      $self->error("Website dir '$fullPath' already exists") if -e $fullPath;

      # use -p because some intermediary dirs might not exist
      $self->runCmd(0, "mkdir -p $fullPath");
  }
}

1;

