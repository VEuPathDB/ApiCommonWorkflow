package ApiCommonWorkflow::Main::WorkflowSteps::CheckOrthoFinderRebuildMode;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

# Combines two independently-computed signals -- "did core change"
# (CheckOrthomclBuildVersion.pm's coreChangedFile) and "did peripheral change"
# (CreatePeripheralOutdatedOrganisms.pm's skipIfFile / doNotDoAnalysis) -- into
# the two single-file gates orthomclPeripheralWorkflow.xml's two mutually
# exclusive subgraphs each need (skipIfFile only supports one file per
# subgraph):
#
#   peripheral unchanged            -> skip both (nothing to do)
#   core changed, peripheral changed -> run full rebuild only
#   core unchanged, peripheral changed -> run incremental only

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $coreChangedFile = join("/", $workflowDataDir, $self->getParamValue("coreChangedFile"));
  my $peripheralUnchangedFile = join("/", $workflowDataDir, $self->getParamValue("peripheralUnchangedFile"));
  my $skipFullRebuildFile = join("/", $workflowDataDir, $self->getParamValue("skipFullRebuildFile"));
  my $skipIncrementalFile = join("/", $workflowDataDir, $self->getParamValue("skipIncrementalFile"));

  if ($undo) {
    $self->runCmd(0, "rm -f $skipFullRebuildFile $skipIncrementalFile");
  }
  elsif ($test) {
    $self->runCmd(0, "touch $skipIncrementalFile");
  }
  else {
    if (-e $peripheralUnchangedFile) {
      $self->runCmd(0, "touch $skipFullRebuildFile");
      $self->runCmd(0, "touch $skipIncrementalFile");
    }
    elsif (-e $coreChangedFile) {
      $self->runCmd(0, "touch $skipIncrementalFile");
    }
    else {
      $self->runCmd(0, "touch $skipFullRebuildFile");
    }
  }
}

1;
