package ApiCommonWorkflow::Main::WorkflowSteps::DoTranscriptExpression;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputDir = $self->getParamValue('inputDir');
  my $outputDir = $self->getParamValue('outputDir');
  my $geneProbeMappingFile = $self->getParamValue('geneProbeMappingFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = <<"EOF";
doTranscriptExpression.pl --xml_file $workflowDataDir/$inputDir/analysisConfig.xml \\
--main_directory $workflowDataDir/$outputDir \\
--input_file $workflowDataDir/$geneProbeMappingFile
EOF

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputDir/*.txt");
  } else {
      if ($test) {
	  $self->testInputFile('inputDir', "$workflowDataDir/$inputDir");
	  $self->testInputFile('geneProbeMappingFile', "$workflowDataDir/$geneProbeMappingFile");
	  $self->runCmd(0,"echo test > $workflowDataDir/$outputDir/profiles.txt");
      }else{
	  makeSymLinks($inputDir, $outputDir);
	  $self->runCmd($test,$cmd);
      }
  }
}

sub makeSymLinks {
  my ($inputDir, $outputDir) = @_;

  opendir(my $dh, $inputDir) || die "can't opendir $inputDir: $!";
  while(readdir($dh)) {
  }
    closedir $dh;

}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

