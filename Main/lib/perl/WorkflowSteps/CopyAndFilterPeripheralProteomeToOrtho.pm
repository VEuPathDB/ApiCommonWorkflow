package ApiCommonWorkflow::Main::WorkflowSteps::CopyAndFilterPeripheralProteomeToOrtho;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $peripheralProteomesDir = join("/", $workflowDataDir, $self->getParamValue("orthoPeripheralDir"));
  my $proteinsFile = join("/", $workflowDataDir, $self->getParamValue("proteinsFile"));
  my $orthomclAbbrev = $self->getParamValue("orthomclAbbrev");
  my $organismAbbrev = $self->getParamValue("organismAbbrev");
  my $gusConfigFile = $self->getGusConfigFile();

  my $outputFasta = "$peripheralProteomesDir/${orthomclAbbrev}.fasta";
  my $pseudogenesFile = $self->getStepDir() . "/pseudogeneProteins.txt";

  if ($undo) {
      $self->runCmd(0, "rm -rf $outputFasta");
  }
  elsif ($test) {
      $self->runCmd(0, "echo 'test' > $outputFasta");
  }
  else {
      $self->runCmd($test, "dumpPseudogeneProteins.pl --outputFile $pseudogenesFile --organismAbbrev $organismAbbrev --gusConfigFile $gusConfigFile");
      $self->runCmd($test, "removePseudogenesFromFasta.pl --inputFasta $proteinsFile --pseudogenes $pseudogenesFile --outputFasta $outputFasta");
  }
}

1;
