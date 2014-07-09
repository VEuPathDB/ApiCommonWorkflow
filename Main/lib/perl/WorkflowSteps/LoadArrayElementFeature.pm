package ApiCommonWorkflow::Main::WorkflowSteps::LoadArrayElementFeature;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {

  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');

  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');

  my $workflowDataDir = $self->getWorkflowDataDir();
  
  my $args = "--extDbSpec '$extDbRlsSpec'  --fileName $workflowDataDir/$inputFile";

  $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");

  $self->runPlugin($test, $undo,"ApiCommonData::Load::Plugin::LoadArrayElementFeature", $args);
}

1;
