package ApiCommonWorkflow::Main::WorkflowSteps::TpmFromHtseqCounts;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;



sub run {
  my ($self, $test, $undo) = @_;

  my $geneFootprintFile = $self->getParamValue('geneFootprintFile');
  my $studyDirectory = $self->getParamValue('studyDir');
  my $analysisConfig = $self->getParamValue('analysisConfig');
  my $isStrandSpecific = $self->getBooleanParamValue('strandSpecific');
  my $outputDir = $self->getParamValue('outputDir');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "makeTpmFromHtseqCounts.pl --outputDir $workflowDataDir/$outputDir --geneFootprintFile $workflowDataDir/$geneFootprintFile --studyDir $workflowDataDir/$studyDirectory --analysisConfig $workflowDataDir/$analysisConfig";

  if($isStrandSpecific) {
    $cmd = $cmd . " --isStranded";
  }

  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputDir");
  }else {
    if ($test) {
        $self->testInputFile('geneFootprintFile', "$workflowDataDir/$geneFootprintFile");
        $self->testInputFile('studyDirectory', "$workflowDataDir/$studyDirectory");
        $self->testInputFile('analysisConfig', "$workflowDataDir/$analysisConfig");
    } else {
      $self->runCmd($test, $cmd);
    }
  }

}

1;
