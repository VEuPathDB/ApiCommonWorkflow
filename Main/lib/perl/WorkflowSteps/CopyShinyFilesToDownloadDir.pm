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
  my $inputFileBaseName = $self->getParamValue('inputFileBaseName');
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
  # $self->runCmd($test, "mkdir -p $copyToDir");
  # $self->runCmd($test, "printf \"IndexIgnore *\" > $websiteFilesDir/$downloadDir/.htaccess");
  # $self->runCmd($test, "printf \"IndexIgnoreReset ON\nIndexIgnore ..\" > $copyToDir/.htaccess");
  # if($nameForFilenames ne ""){
  #   $self->runCmd($test, "cd $workflowDataDir/$datasetName/; rename $inputFileBaseName $nameForFilenames ./$inputFileBaseName*");
  #   $self->runCmd($test, "cp $workflowDataDir/$datasetName/$nameForFilenames* $copyToDir/");
  # }
  # else{
  #   $self->runCmd($test, "rename $inputFileBaseName $datasetName $workflowDataDir/$datasetName/$inputFileBaseName*");
  #   $self->runCmd($test, "cp $workflowDataDir/$datasetName/$datasetName* $copyToDir/");
  # }
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
    opendir(DH, "$workflowDataDir/$datasetName") or die "Cannot read directory: $!";
    my @files = grep { /$datasetName/ } readdir(DH);
    closedir(DH);
    foreach my $file (@files){
      my $unzippedName = $file;
      # Remove a prefix
      $unzippedName =~ s/^.*PREFIX_//;
      if($nameForFilenames) {
        $unzippedName = $nameForFilenames . ".txt";
      }
      my $zipFile = basename($unzippedName, ".txt") . ".zip";
      zip("$workflowDataDir/$datasetName/$file" => "$copyToDir/$zipFile", "Name" => $unzippedName) or die "Zip failed: $!";
    }
    # clean up data dir
    foreach my $file (@files){
      unlink("$workflowDataDir/$datasetName/$file");
    }
  }
}

1;
