package ApiCommonWorkflow::Main::WorkflowSteps::MakeControlFilesForSNPs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $sequenceVariationCtl = $self->getParamValue('sequenceVariationCtl');
  my $snpCtl = $self->getParamValue('snpCtl');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "makeControlFilesForSNPs --sequence_variation_ctl $workflowDataDir/$sequenceVariationCtl --snp_ctl $workflowDataDir/$snpCtl";

  if($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$sequenceVariationCtl");
    $self->runCmd(0, "rm -f $workflowDataDir/$snpCtl");
  } else {
    if($test) {
      $self->runCmd(0, "echo test > $workflowDataDir/$sequenceVariationCtl");
      $self->runCmd(0, "echo test > $workflowDataDir/$snpCtl");
    }
    $self->runCmd($test, $cmd);

  }
}


1;
