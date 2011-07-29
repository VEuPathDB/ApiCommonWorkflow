package ApiCommonWorkflow::Main::WorkflowSteps::DoTranscriptExpression;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputDir = $self->getParamValue('inputDir');
  my $outputDir = $self->getParamValue('outputDir');
  my $geneProbeMappingTabFile = $self->getParamValue('geneProbeMappingTabFile');
  my $geneProbeMappingVendorFile = $self->getParamValue('geneProbeMappingVendorFile');
  my $expectCdfFile = $self->getParamValue('expectCdfFile');
  my $expectNdfFile = $self->getParamValue('expectNdfFile');

  my $mappingFile = ($expectCdfFile || $expectNdfFile)?
      $geneProbeMappingVendorFile : $geneProbeMappingTabFile;

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = <<"EOF";
doTranscriptExpression.pl --xml_file $workflowDataDir/$inputDir/analysisConfig.xml \\
--main_directory $workflowDataDir/$outputDir \\
--input_file $workflowDataDir/$mappingFile
EOF

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputDir");
  } else {
      $self->runCmd(0, "mkdir $workflowDataDir/$outputDir");
      if ($test) {
	  $self->testInputFile('inputDir', "$workflowDataDir/$inputDir");
	  $self->testInputFile('geneProbeMappingFile', "$workflowDataDir/$mappingFile");
	  $self->runCmd(0,"echo test > $workflowDataDir/$outputDir/profiles.txt");
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

