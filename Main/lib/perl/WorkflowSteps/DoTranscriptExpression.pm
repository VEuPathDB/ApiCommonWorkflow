package ApiCommonWorkflow::Main::WorkflowSteps::DoTranscriptExpression;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $analysisConfigFile = $self->getParamValue('analysisConfigFile');
  my $inputDir = $self->getParamValue('inputDir');
  my $outputDir = $self->getParamValue('outputDir');
  my $geneProbeMappingTabFile = $self->getParamValue('geneProbeMappingTabFile');
  my $geneProbeMappingVendorFile = $self->getParamValue('geneProbeMappingVendorFile');
  my $expectCdfFile = $self->getBooleanParamValue('expectCdfFile');
  my $expectNdfFile = $self->getBooleanParamValue('expectNdfFile');

  my $mappingFile = ($expectCdfFile || $expectNdfFile)?
      $geneProbeMappingVendorFile : $geneProbeMappingTabFile;

  my $workflowDataDir = $self->getWorkflowDataDir();

  # mapping file is optional.  not used for rna seq
  my $input_file = $mappingFile?
      "--input_file $workflowDataDir/$mappingFile" : "";

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "doTranscriptExpression.pl --xml_file $workflowDataDir/$analysisConfigFile --main_directory $workflowDataDir/$outputDir $input_file";

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputDir");
  } else {
      $self->runCmd(0, "mkdir $workflowDataDir/$outputDir");
      if ($test) {
	  $self->testInputFile('inputDir', "$workflowDataDir/$inputDir");
	  $self->testInputFile('geneProbeMappingFile', "$workflowDataDir/$mappingFile") if $mappingFile;
	  $self->testInputFile('analysisConfigFile', "$workflowDataDir/$analysisConfigFile");
	  $self->runCmd(0,"echo test > $workflowDataDir/$outputDir/profiles.txt");
	  $self->runCmd(0,"echo test > $workflowDataDir/$outputDir/expression_profile_config.txt");
      } else {
	  makeSymLinks($inputDir, $outputDir);
	  $self->runCmd($test,$cmd);
      }
  }
}

# initialize output dir with symlinks to all files in input dir
# this is needed by doTranscriptExpresssion command
sub makeSymLinks {
  my ($self, $inputDir, $outputDir) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();

  opendir(my $dh, "$workflowDataDir/$inputDir") || $self->error("can't opendir $workflowDataDir/$inputDir: $!");
  while(readdir($dh)) {
      next if /^\.+/;
      symlink("$workflowDataDir/$inputDir/$_", "$workflowDataDir/$outputDir/$_") || $self->error("Can't make symlink from $workflowDataDir/$inputDir/$_ to $workflowDataDir/$outputDir/$_");
  }
    closedir $dh;
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

