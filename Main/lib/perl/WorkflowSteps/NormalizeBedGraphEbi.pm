package ApiCommonWorkflow::Main::WorkflowSteps::NormalizeBedGraphEbi;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputDir = $self->getParamValue('inputDir');
  my $topLevelSeqSizeFile = $self->getParamValue('topLevelSeqSizeFile');
  my $analysisConfig = $self->getParamValue('analysisConfig');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd= "normalizeCoverageEbi.pl --inputDir $workflowDataDir/$inputDir --topLevelSeqSizeFile $workflowDataDir/$topLevelSeqSizeFile --analysisConfig $workflowDataDir/$analysisConfig";

  if($undo){
      # can't undo this step.  must undo cluster task
  }else{
    if ($test) {
        $self->testInputFile('inputDir', "$workflowDataDir/$inputDir");
        $self->testInputFile('topLevelSeqSizeFile', "$workflowDataDir/$topLevelSeqSizeFile");
        $self->testInputFile('analysisConfig', "$workflowDataDir/$analysisConfig");
    } else {
        $self->runCmd($test, $cmd);
    }
  }
}

1;
