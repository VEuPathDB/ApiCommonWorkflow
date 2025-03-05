package ApiCommonWorkflow::Main::WorkflowSteps::CopyShinyFilesToDownloadDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

use Digest::SHA qw(sha1_hex);
use IO::Compress::Zip qw/zip/;
use File::Copy;
use File::Path qw/make_path remove_tree/;
use File::Basename;

sub run {
  my ($self, $test, $undo) = @_;

  my $datasetName = $self->getParamValue('datasetName');
  my $nameForFilenames= $self->getParamValue('nameForFilenames');
  my $filePath= $self->getParamValue('filePath');
  my $downloadDir = $self->getParamValue('relativeDownloadSiteDir');

  # standard parameters for making download files
  my $websiteFilesDir = $self->getWebsiteFilesDir($test);
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $digest = sha1_hex($datasetName);
  my $copyToDir = "$websiteFilesDir/$downloadDir/$digest";

  if($undo) {
    # $self->runCmd(0, "rm -f $copyToDir/*");
  }
  else{
   if($test){
	    # $self->runCmd(0, "mkdir -p $copyToDir");
      make_path($copyToDir) unless( -d $copyToDir);
      $self->log("This WorkflowStep package does not run any tests");
      return;
    }
    make_path($copyToDir) unless( -d $copyToDir);
  # htaccess
    open(FH, ">$websiteFilesDir/$downloadDir/.htaccess") or die "Cannot create .htaccess: $!";
    printf FH ("IndexIgnore *\n");
    close(FH);
  # htaccess
    open(FH, ">$copyToDir/.htaccess") or die "Cannot create .htaccess: $!";
    printf FH ("IndexIgnoreReset ON\nIndexIgnore ..\n");
    close(FH);
  # create zips in destination
    opendir(DH, "$workflowDataDir/$filePath") or die "Cannot read directory: $!";
    my @files = grep { /$datasetName/ } readdir(DH);
    closedir(DH);
    foreach my $file (@files){
      my $unzippedName = $file;
      # Remove a prefix
      $unzippedName =~ s/^.*PREFIX_//;
      if($nameForFilenames && $nameForFilenames =~ /^s\/.*\/.*\//) {
        eval sprintf("\$unzippedName =~ %s", $nameForFilenames);
      }
      #my $zipFile = basename($unzippedName, ".txt") . ".zip";
      my $zipFile = $unzippedName . ".zip";
      $unzippedName = basename($unzippedName);
      zip("$workflowDataDir/$filePath/$file" => "$copyToDir/$zipFile", "Name" => $unzippedName) or die "Zip failed: $!";
      printf STDERR ("$workflowDataDir/$filePath/$file => \n\t$copyToDir/$zipFile\n");
    }
    # Don't clean up data dir
    # foreach my $file (@files){
    #   unlink("$workflowDataDir/$datasetName/$file");
    # }
  }
  printf STDERR ("done.");
}

1;
