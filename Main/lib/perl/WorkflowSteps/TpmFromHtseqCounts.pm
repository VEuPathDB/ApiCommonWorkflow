package ApiCommonWorkflow::Main::WorkflowSteps::TpmFromHtseqCounts;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;



sub run {
  my ($self, $test, $undo) = @_;

  my $geneFootprintFile = $self->getParamValue('geneFootprintFile');
  my $samplesDirectory = $self->getParamValue('samplesDir');
  my $analysisConfig = $self->getParamValue('analysisConfig');
  my $isStrandSpecific = $self->getBooleanParamValue('strandSpecific');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "makeTpmFromHtseqCounts.pl --geneFootprintFile $workflowDataDir/$geneFootprintFile --studyDir $workflowDataDir/$samplesDirectory --analysisConfig $workflowDataDir/$analysisConfig";

  if($isStrandSpecific) {
    $cmd = $cmd . " --isStranded";
  }

  if ($undo) {
      $self->runCmd(0, "rm $workflowDataDir/$samplesDirectory/*/*.tpm");
  }else {
    if ($test) {
        $self->testInputFile('geneFootprintFile', "$workflowDataDir/$geneFootprintFile");
        $self->testInputFile('samplesDirectory', "$workflowDataDir/$samplesDirectory");
        $self->testInputFile('analysisConfig', "$workflowDataDir/$analysisConfig");
    } else {
      $self->runCmd($test, $cmd);
    }
  }

}

1;
