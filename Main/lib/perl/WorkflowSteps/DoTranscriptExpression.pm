package ApiCommonWorkflow::Main::WorkflowSteps::DoTranscriptExpression;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputDir = $self->getParamValue('inputDir');
  my $probeGenesMappingFile = $self->getParamValue('probeGenesMappingFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = <<"EOF";
doTranscriptExpression.pl --xml_file $workflowDataDir/$inputDir/analysisConfig.xml \\
--main_directory $workflowDataDir/$inputDir/ \\
--input_file $workflowDataDir/$probeGenesMappingFile
EOF

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$inputDir/*.txt");
  } else {
      if ($test) {
	  $self->testInputFile('inputDir', "$workflowDataDir/$inputDir");
	  $self->testInputFile('probeGenesMappingFile', "$workflowDataDir/$probeGenesMappingFile");
	  $self->runCmd(0,"echo test > $workflowDataDir/$inputDir/profiles.txt");
      }else{
	  $self->runCmd($test,$cmd);
      }
  }
}

sub getParamDeclaration {
  return (
	  'inputDir',
	  'probeGenesMappingFile',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

