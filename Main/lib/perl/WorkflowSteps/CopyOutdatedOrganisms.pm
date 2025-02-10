package ApiCommonWorkflow::Main::WorkflowSteps::CopyOutdatedOrganisms;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $outdatedOrganisms = $self->getSharedConfig("outdatedOrganisms");
  my $outputDir = join("/", $workflowDataDir, $self->getParamValue("outputDir"));

  if ($undo) {
      $self->runCmd(0, "rm -rf $outputDir/outdated.txt");
  }
  elsif ($test) {
      $self->runCmd(0, "touch $outputDir/outdated.txt");
  }
  else {
      $self->runCmd(0, "cp -r ${outdatedOrganisms} $outputDir/outdated.txt");
      die "$outputDir/outdated.txt does not exist" unless(-e "$outputDir/outdated.txt");
  }
}

1;
