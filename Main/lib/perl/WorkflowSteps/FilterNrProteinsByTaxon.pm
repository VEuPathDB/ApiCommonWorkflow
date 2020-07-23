package ApiCommonWorkflow::Main::WorkflowSteps::FilterNrProteinsByTaxon;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test,$undo) = @_;

  my $nrFile = $self->getParamValue('nrFile');
  my $taxaFilter = $self->getParamValue('taxaFilter');
  my $queryFile = $self->getParamValue('queryFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$queryFile");
  } else {  
    $self->testInputFile('nrFile', "$workflowDataDir/$nrFile");

    $self->runCmd($test, "filterNrByTaxa.pl --nrFile $workflowDataDir/$nrFile --taxaFilter $taxaFilter --outputFile $workflowDataDir/$queryFile");
  }
}

1;

