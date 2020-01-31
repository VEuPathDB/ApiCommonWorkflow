package ApiCommonWorkflow::Main::WorkflowSteps::DoTranscriptExpressionEbi;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $analysisConfigFile = $self->getParamValue('analysisConfigFile');
  my $inputDir = $self->getParamValue('inputDir');
  my $outputDir = $self->getParamValue('outputDir');
  my $seqIdPrefix = $self->getParamValue('seqIdPrefix');
  my $technologyType = $self->getParamValue("technologyType");

  my $workflowDataDir = $self->getWorkflowDataDir();


  my $cmd = "doTranscriptExpression.pl --xml_file $workflowDataDir/$analysisConfigFile --main_directory $workflowDataDir/$outputDir $input_file --technology_type $technologyType --seq_id_prefix $seqIdPrefix";

  if ($undo) {
    $self->runCmd(0, "rm -rf $workflowDataDir/$outputDir");
  } else {
      # clean up previous failure
      if(-d "$workflowDataDir/$outputDir") {
        $self->runCmd(0, "rm -rf $workflowDataDir/$outputDir");
      }
  
      $self->runCmd(0, "mkdir $workflowDataDir/$outputDir");

      $self->testInputFile('inputDir', "$workflowDataDir/$inputDir");
      $self->testInputFile('analysisConfigFile', "$workflowDataDir/$analysisConfigFile");

      if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputDir/analysis_result_config.txt **optional**");
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputDir/insert_study_results_config.txt");
      }
      $self->runCmd($test,$cmd);
  }
}

1;
