package ApiCommonWorkflow::Main::WorkflowSteps::TpmFromHtseqCounts;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;



sub run {
  my ($self, $test, $undo) = @_;

  my $geneFootprintFile = $self->getParamValue('geneFootprintFile');
  my $samplesDirectory = $self->getParamValue('samplesDirectory');
  my $isStrandSpecific = $self->getBooleanParamValue('isStrandSpecific');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "makeTpmFromHtseqCounts.pl --geneFootprintFile ${workflowDataDir}/${geneFootprintFile} --studyDir ${workflowDataDir}/$samplesDirectory";

  if($isStrandSpecific) {
    $cmd = $cmd . " --isStranded";
  }

  if ($undo) {
      $self->runCmd(0, "rm ${workflowDataDir}/$samplesDirectory/*/*.tpm");
  }else {
      $self->runCmd($test, $cmd);
  }

}

1;
