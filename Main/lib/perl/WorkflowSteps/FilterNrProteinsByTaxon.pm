package ApiCommonWorkflow::Main::WorkflowSteps::FilterNrProteinsByTaxon;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test,$undo) = @_;

  my $taxaFilter = $self->getParamValue('taxaFilter');
  my $nrdbFile = $self->getParamValue('nrdbFile');
  my $queryFile = $self->getParamValue('queryFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$queryFile");
  } else {
    if($test) {
      $self->runCmd(0, "echo test > $workflowDataDir/$queryFile");
    }
    else {
      $self->testInputFile('nrFile', "$workflowDataDir/$nrdbFile");
      $self->runCmd($test, "filterNrByTaxa.pl --nrdbFile $workflowDataDir/$nrdbFile --taxaFilter $taxaFilter --outputFile $workflowDataDir/$queryFile");
    }
  }
}

1;

