package ApiCommonWorkflow::Main::WorkflowSteps::CopyOutdatedFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $outdated = join("/",$self->getSharedConfig("orthoCacheDir"),"outdated.txt");
  my $outputDir = join("/", $workflowDataDir, $self->getParamValue("outputDir"));

  if ($undo) {
      $self->runCmd(0, "rm -rf $outputDir/outdated.txt");
  }
  elsif ($test) {
      $self->runCmd(0, "touch $outputDir/outdated.txt");
  }
  else {
      $self->runCmd(0, "cp ${outdated} $outputDir/");
  }
}

1;
