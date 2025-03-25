package ApiCommonWorkflow::Main::WorkflowSteps::NormalizeBedGraphEbi;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputDir = $self->getParamValue('inputDir');
  my $seqSizeFile = $self->getParamValue('seqSizeFile');
  my $analysisConfig = $self->getParamValue('analysisConfig');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd= "normalizeCoverageEbi.pl --inputDir $workflowDataDir/$inputDir --seqSizeFile $workflowDataDir/$seqSizeFile --analysisConfig $workflowDataDir/$analysisConfig";

  if($undo){
      $self->runCmd(0, "rm -rf $workflowDataDir/$inputDir/normalize_coverage");
      # can't undo this step.  must undo cluster task
  }else{
    if ($test) {
        $self->testInputFile('inputDir', "$workflowDataDir/$inputDir");
        $self->testInputFile('seqSizeFile', "$workflowDataDir/$seqSizeFile");
        $self->testInputFile('analysisConfig', "$workflowDataDir/$analysisConfig");
    } else {
        $self->runCmd($test, $cmd);
    }
  }
}

1;
