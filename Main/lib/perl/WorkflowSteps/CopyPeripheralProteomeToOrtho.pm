package ApiCommonWorkflow::Main::WorkflowSteps::CopyPeripheralProteomeToOrtho;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $peripheralProteomesDir = join("/", $workflowDataDir, $self->getParamValue("orthoPeripheralDir"));
  my $proteinsFile = join("/", $workflowDataDir, $self->getParamValue("proteinsFile"));
  my $orthomclAbbrev = $self->getParamValue("orthomclAbbrev");

  if ($undo) {
      $self->runCmd(0, "rm -rf $peripheralProteomesDir/${orthomclAbbrev}.fasta");
  }
  elsif ($test) {
      $self->runCmd(0, "echo 'test' > $peripheralProteomesDir/${orthomclAbbrev}.fasta");
  }
  else {
      $self->runCmd(0, "ln -s ${proteinsFile} $peripheralProteomesDir/${orthomclAbbrev}.fasta");
  }
}

1;
