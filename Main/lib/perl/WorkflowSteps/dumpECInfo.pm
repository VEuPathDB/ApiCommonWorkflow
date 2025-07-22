package ApiCommonWorkflow::Main::WorkflowSteps::dumpECInfo;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $dataDir = $self->getParamValue('dataDir');
  my $workflowDataDir = $self->getWorkflowDataDir();
  $dataDir = "$workflowDataDir/$dataDir";

  my $cmd = "orthoGetDataFromVeupathAndUniprot.pl --dataDir $dataDir";

  if ($undo) {
    $self->runCmd(0, "rm -fr $dataDir/*");
  } else {
    $self->runCmd($test,$cmd);
  }
}

1;

