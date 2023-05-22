package ApiCommonWorkflow::Main::WorkflowSteps::PatchStudyAssayResults;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $analysisConfigFile = $self->getParamValue('analysisConfigFile');
  my $outputDir = $self->getParamValue('outputDir');
  my $technologyType = $self->getParamValue("technologyType");

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $ancillaryFile = $analysisConfigFile;
  $ancillaryFile =~ s/analysisConfig.xml/ancillary.txt/;


  my $cmd = "doStudyAssayResults.pl --xml_file $workflowDataDir/$analysisConfigFile --main_directory $workflowDataDir/$outputDir --technology_type $technologyType --patch";

  $cmd = $cmd . " --input_file $workflowDataDir/$ancillaryFile" if (-e "$workflowDataDir/$ancillaryFile");

  if ($undo) {
    $self->runCmd(0, "rm $workflowDataDir/$outputDir/insert_study_results_config.txt");
  } else {

      $self->testInputFile('analysisConfigFile', "$workflowDataDir/$analysisConfigFile");
      $self->testInputFile('outputDir', "$workflowDataDir/$outputDir");

      if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputDir/insert_study_results_config.txt");
      }
      $self->runCmd($test,$cmd);
  }
}

1;
