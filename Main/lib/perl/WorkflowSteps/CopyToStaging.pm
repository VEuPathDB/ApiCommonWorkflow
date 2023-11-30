package ApiCommonWorkflow::Main::WorkflowSteps::CopyToStaging;

# COPY IS RECURSIVE

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

use File::Path qw/make_path remove_tree/;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $filePath= join("/", $workflowDataDir, $self->getParamValue('filePath'));
  my $downloadDir = $self->getParamValue('relativeDownloadSiteDir');

  # standard parameters for making download files, set in workflow config/rootParams.prop 
  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  my $copyToDir = "$websiteFilesDir/$downloadDir/";

  if($undo) {
    $self->runCmd(0, "rm -fr $copyToDir/*");
  }
  else{
   if($test){
	    # $self->runCmd(0, "mkdir -p $copyToDir");
      make_path($copyToDir) unless( -d $copyToDir);
      $self->log("This WorkflowStep package does not run any tests");
      return;
    }
    make_path($copyToDir) unless( -d $copyToDir);
  # htaccess, parent dir
    unless(-e "$websiteFilesDir/$downloadDir/.htaccess"){
      open(FH, ">$websiteFilesDir/$downloadDir/.htaccess") or die "Cannot create .htaccess: $!";
      printf FH ("IndexIgnore *\n");
      close(FH);
    }
  # htaccess
    open(FH, ">$copyToDir/.htaccess") or die "Cannot create .htaccess: $!";
    printf FH ("IndexIgnoreReset ON\nIndexIgnore ..\n");
    close(FH);
    $self->runCmd($test, "cp -v -r $filePath $copyToDir");
  }
  printf STDERR ("done.");
}

1;

