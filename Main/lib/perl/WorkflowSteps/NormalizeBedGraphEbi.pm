package ApiCommonWorkflow::Main::WorkflowSteps::NormalizeBedGraph;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputDir = $self->getParamValue('inputDir');
  my $topLevelSeqSizeFile = $self->getParamValue('topLevelSeqSizeFile');
  my $seqIdPrefix = $self->getParamValue('seqIdPrefix');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd= "normalizeCoverage.pl --inputDir $workflowDataDir/$inputDir --topLevelSeqSizeFile $workflowDataDir/$topLevelSeqSizeFile --seqIdPrefix $seqIdPrefix";

  if($undo){
      # can't undo this step.  must undo cluster task
  }else{
    $self->testInputFile('inputDir', "$workflowDataDir/$inputDir");
    $self->testInputFile('topLevelSeqSizeFile', "$workflowDataDir/$topLevelSeqSizeFile");
    $self->runCmd($test, $cmd);
  }
}

1;
