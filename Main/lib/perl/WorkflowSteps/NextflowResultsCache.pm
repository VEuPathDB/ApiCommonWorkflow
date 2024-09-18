package ApiCommonWorkflow::Main::WorkflowSteps::NextflowResultsCache;
@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use File::Basename;


sub run {
  my ($self, $test, $undo) = @_;

  my $mode = $self->getParamValue('mode');

  my $parentDataPath  = $self->getParamValue("parentDataPath");
  my $analysisDirectory = basename($parentDataPath);

  my $preprocessedDataCache = $self->getSharedConfig('preprocessedDataCache');
  my $workflowName = $self->getWorkflowConfig('name');
  my $workflowVersion = $self->getWorkflowConfig('version');

  my $foundNextflowResults = $self->getParamValue("foundNextflowResults");
  my $resultsDir = $self->getParamValue("resultsDir");

  my ($genomeName, $genomeVersion) = split(/\|/, $self->getParamValue("genomeSpec"));

  my $cacheDirBase = "$preprocessedDataCache/$workflowName/$workflowVersion/$genomeName/$genomeVersion";

  my $cacheDir = "$cacheDirBase/$analysisDirectory";

  if($self->getParamValue("annotationSpec")) {
      my $annotationDirectory = $self->getParamValue("annotationSpec");
      $annotationDirectory =~ s/\|/_/g;
      $cacheDir = "$cacheDirBase/$annotationDirectory/$analysisDirectory";
  }

  my $resultsPath = $self->getWorkflowDataDir() . "/" . $resultsDir;
  my $foundNextflowResultsFile = $self->getWorkflowDataDir() . "/" . $foundNextflowResults;

  if($mode eq "copyTo") {

    if($undo) {} #nothing to see here
    else {
      $self->runCmd($test, "mkdir -p $cacheDir");
      $self->runCmd($test, "cp -r $resultsPath/* $cacheDir/");
    }

  }
  else {
    my $hasCacheFile = 0;
    if(-d $cacheDir) {
      opendir(my $dh, $cacheDir) or die "Can't open $cacheDir for reading: $!";
      while (readdir($dh)) {
        next if ($_ eq '.' or $_ eq '..');
        closedir($dh);
        $hasCacheFile = 1;
      }
      closedir($dh);
    }

    if($undo) {
      $self->runCmd($test, "rm -f $foundNextflowResultsFile");
      $self->runCmd($test, "rm -rf $resultsPath/*");
    }
    else {
      if($hasCacheFile) {

        $self->runCmd($test, "touch $foundNextflowResultsFile");
        $self->runCmd($test, "cp -r $cacheDir/* $resultsPath");
      }
    }

  }



}

1;
