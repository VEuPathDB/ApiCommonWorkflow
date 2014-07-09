package ApiCommonWorkflow::Main::WorkflowSteps::LoadExpressionFeature;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');

  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');

  my $featureType = $self->getParamValue('featureType');

  my $workflowDataDir = $self->getWorkflowDataDir();
      
  my $args = "--tagToSeqFile $workflowDataDir/$inputFile --extDbSpec '$extDbRlsSpec' --featureType $featureType";


  $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");


  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::LoadExpressionFeature", $args);

}

1;
