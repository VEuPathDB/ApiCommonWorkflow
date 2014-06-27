package ApiCommonWorkflow::Main::WorkflowSteps::InsertExportPred;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--inputFile $workflowDataDir/$inputFile --seqTable DoTS::AASequence --seqExtDbRlsSpec '$genomeExtDbRlsSpec' --extDbRlsSpec '$genomeExtDbRlsSpec'";


    $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");


  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertExportPredFeature", $args);

}

1;

