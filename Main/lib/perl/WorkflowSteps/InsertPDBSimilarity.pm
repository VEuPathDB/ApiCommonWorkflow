package ApiCommonWorkflow::Main::WorkflowSteps::InsertPDBSimilarity;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');

  my $workflowDataDir = $self->getWorkflowDataDir();

  #$self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
  my $args = "--inputFile $workflowDataDir/$inputFile.gz --extDbRlsSpec '$genomeExtDbRlsSpec'";

  $self->runPlugin($test,$undo, "ApiCommonData::Load::Plugin::InsertPDBSimilarity", $args);
}


1;
