package ApiCommonWorkflow::Main::WorkflowSteps::MakeGffBigWigFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::Util::OrganismInfo;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $inputsDir = $self->getParamValue('inputsDir');
  my $chromSizesFile = $self->getParamValue('chromSizesFile');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $relativeDir = $self->getParamValue('relativeDir');
  my $experimentDatasetName = $self->getParamValue('experimentDatasetName');
  my $copyGFFToWS = $self->getBooleanParamValue('copyGFFToWS');

  my $websiteFilesDir = $self->getWebsiteFilesDir($test);
  my $gusConfigFile = $self->getParamValue('gusConfigFile');
  $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";

  my $organismNameForFiles =
      $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getNameForFiles();

  my $bigwigOutputDir = "$websiteFilesDir/$relativeDir/$organismNameForFiles/prealigned/bigwig/$experimentDatasetName";

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd_mkdir_bigwig = "mkdir -p $bigwigOutputDir";

  my $cmd_createBigWig = "createGffBigWigFile --inputDir $workflowDataDir/$inputsDir --chromSizesFile $workflowDataDir/$chromSizesFile --outputDir $bigwigOutputDir";

  $self->testInputFile('copyFromDir', "$workflowDataDir/$inputsDir");

  if ($undo) {
    $self->runCmd(0, "rm -fr $bigwigOutputDir");
    if ($copyGFFToWS) {
      my $gffOutputDir = "$websiteFilesDir/$relativeDir/$organismNameForFiles/prealigned/gff/$experimentDatasetName";
      $self->runCmd(0, "rm -fr $gffOutputDir");
    }
  } else {
    $self->runCmd($test, $cmd_mkdir_bigwig);
    $self->runCmd($test, $cmd_createBigWig);

    if ($copyGFFToWS) {
      my $gffOutputDir = "$websiteFilesDir/$relativeDir/$organismNameForFiles/prealigned/gff/$experimentDatasetName";
      my $cmd_mkdir_gff = "mkdir -p $gffOutputDir";

      $self->runCmd($test, $cmd_mkdir_gff);

      my @gffFiles = glob("$workflowDataDir/$inputsDir/*.gff");
      foreach my $gffFile (@gffFiles) {
        my $basename = $gffFile;
        $basename =~ s/.*\///;  # get filename without path
        my $sortedFile = "$gffOutputDir/$basename.sorted";
        my $gzFile = "$gffOutputDir/$basename.gz";

        my $cmd_sort = "sort -k1,1 -k4,4n $gffFile > $sortedFile";
        my $cmd_bgzip = "bgzip -c $sortedFile > $gzFile";
        my $cmd_tabix = "tabix -p gff $gzFile";
        my $cmd_cleanup = "rm -f $sortedFile";

        $self->runCmd($test, $cmd_sort);
        $self->runCmd($test, $cmd_bgzip);
        $self->runCmd($test, $cmd_tabix);
        $self->runCmd($test, $cmd_cleanup);
      }
    }
  }

}

1;


