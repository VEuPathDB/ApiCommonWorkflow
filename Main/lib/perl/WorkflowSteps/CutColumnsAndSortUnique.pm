package ApiCommonWorkflow::Main::WorkflowSteps::CutColumnsAndSortUnique;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $fromFile = $self->getParamValue('fromFile');
  my $toFile = $self->getParamValue('toFile');
  my $cutColumns = $self->getParamValue('cutColumns');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "cut $cutColumns $workflowDataDir/$fromFile | sort -u > $workflowDataDir/$toFile";

  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$toFile");
  } else {
    if (!$test) {
      unless (-s "$workflowDataDir/$fromFile") {
        warn "No from File or from File is empty.\n";
      }
    }
    $self->runCmd($test, $cmd);
  }
}

1;
