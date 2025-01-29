package ApiCommonWorkflow::Main::WorkflowSteps::CopyCoreProteomeToOrtho;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $coreProteomesDir = join("/", $workflowDataDir, $self->getParamValue("orthoCoreDir"));
  my $proteinsFile = join("/", $workflowDataDir, $self->getParamValue("proteinsFile"));
  my $orthomclAbbrev = $self->getParamValue("orthomclAbbrev");

  if ($undo) {
      $self->runCmd(0, "rm -rf $coreProteomesDir/${orthomclAbbrev}.fasta");
  }
  elsif ($test) {
      $self->runCmd(0, "echo 'test' > $coreProteomesDir/${orthomclAbbrev}.fasta");
  }
  else {
      $self->runCmd(0, "ln -s ${proteinsFile} $coreProteomesDir/${orthomclAbbrev}.fasta");
  }
}

1;
