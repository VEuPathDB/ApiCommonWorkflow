package ApiCommonWorkflow::Main::WorkflowSteps::RenameGroupIds;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

# Applies a group-ID rename map (from ComputeGroupIdRenameMap) to a single loader-facing
# file, in place. Reusable across every group-ID-keyed file this pipeline produces --
# invoked once per target file, each with its own paramValues. A line whose group ID isn't
# in the map (an untouched group) passes through byte-identical, so this is safe to run
# even when the map is empty (nothing touched this run).

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $renameMap = join("/", $workflowDataDir, $self->getParamValue("renameMap"));
  my $inputFile = join("/", $workflowDataDir, $self->getParamValue("inputFile"));
  my $format = $self->getParamValue("format");
  my $columns = $self->getParamValue("columns");

  if ($undo) {
    $self->runCmd(0, "echo 'undo'");
  }
  elsif ($test) {
    $self->runCmd(0, "echo 'test'");
  }
  else {
    $self->testInputFile('renameMap', $renameMap);
    $self->testInputFile('inputFile', $inputFile);

    my $columnsArg = $columns ? "--columns $columns" : "";

    $self->runCmd(0, "renameGroupIds --renameMap $renameMap --input $inputFile --format $format $columnsArg --output ${inputFile}.renamed");
    $self->runCmd(0, "mv ${inputFile}.renamed $inputFile");
  }
}

1;
