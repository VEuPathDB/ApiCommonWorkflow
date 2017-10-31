package ApiCommonWorkflow::Main::WorkflowSteps::DoTranscriptExpression;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $analysisConfigFile = $self->getParamValue('analysisConfigFile');
  my $inputDir = $self->getParamValue('inputDir');
  my $outputDir = $self->getParamValue('outputDir');

  # geneProbeMapping.tab
  my $geneProbeMappingTabFile = $self->getParamValue('geneProbeMappingTabFile'); 
  my $platformDirectory = $self->getParamValue('platformDirectory'); 

  my $passPlatformMappingFile = $self->getBooleanParamValue('passPlatformMappingFile');

  my $expectCdfFile = $self->getBooleanParamValue('expectCdfFile');
  my $expectNdfFile = $self->getBooleanParamValue('expectNdfFile');

  my $technologyType = $self->getParamValue("technologyType");

  my $workflowDataDir = $self->getWorkflowDataDir();
  $platformDirectory = "$workflowDataDir/$platformDirectory";

  my ($input_file, $mappingFile);
  if($passPlatformMappingFile) {
    opendir(DIR, $platformDirectory); 
    my @files = readdir(DIR);
    closedir DIR;


    if($expectCdfFile) {
      my @cdfs = grep { /\.cdf$/i} @files;
      $self->error("cdf file error in directory $platformDirectory") if(scalar(@cdfs) != 1);
      $mappingFile = "$platformDirectory/$cdfs[0]"
    }
    elsif($expectNdfFile) {
      my @ndfs = grep { /\.ndf$/i} @files;
      $self->error("ndf file error in directory $platformDirectory") if(scalar(@ndfs) != 1);
      $mappingFile = "$platformDirectory/$ndfs[0]"
    }
    else {
      $mappingFile = $geneProbeMappingTabFile eq '' ? "$platformDirectory/ancillary.txt" : "$platformDirectory/$geneProbeMappingTabFile";
    }
    $input_file = "--input_file $mappingFile";
  }

  my $cmd = "doTranscriptExpression.pl --xml_file $workflowDataDir/$analysisConfigFile --main_directory $workflowDataDir/$outputDir $input_file --technology_type $technologyType";

  if ($undo) {
    $self->runCmd(0, "rm -rf $workflowDataDir/$outputDir");
  } else {
      # clean up previous failure
      if(-d $workflowDataDir/$outputDir) {
        $self->runCmd(0, "rm -rf $workflowDataDir/$outputDir");
      }
  
      $self->runCmd(0, "mkdir $workflowDataDir/$outputDir");

      $self->testInputFile('inputDir', "$workflowDataDir/$inputDir");
      # $self->testInputFile('geneProbeMappingFile', "$mappingFile") if $passPlatformMappingFile;
      $self->testInputFile('analysisConfigFile', "$workflowDataDir/$analysisConfigFile");

      if ($test) {
	  $self->runCmd(0,"echo test > $workflowDataDir/$outputDir/expression_profile_config.txt");
	  $self->runCmd(0,"echo test > $workflowDataDir/$outputDir/analysis_result_config.txt **optional**");
	  $self->runCmd(0,"echo test > $workflowDataDir/$outputDir/insert_study_results_config.txt");
      }
      if(!$test) {
        $self->makeSymLinks($inputDir, $outputDir);
      }
      $self->runCmd($test,$cmd);
  }
}

# initialize output dir with symlinks to all files in input dir
# this is needed by doTranscriptExpresssion command
sub makeSymLinks {
  my ($self, $inputDir, $outputDir) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();

  opendir(my $dh, "$workflowDataDir/$inputDir") || $self->error("can't opendir $workflowDataDir/$inputDir: $!");
  while(my $file = readdir($dh)) {
      next if $file =~ /^\.+/;
      symlink("$workflowDataDir/$inputDir/$file", "$workflowDataDir/$outputDir/$file") || $self->error("Can't make symlink from $workflowDataDir/$inputDir/$file to $workflowDataDir/$outputDir/$file");
  }
    closedir $dh;
}

1;
