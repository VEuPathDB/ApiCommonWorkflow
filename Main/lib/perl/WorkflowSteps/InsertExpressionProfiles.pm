package ApiCommonWorkflow::Main::WorkflowSteps::InsertExpressionProfiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $configFile = $self->getParamValue('configFile');

  my $inputDir = $self->getParamValue('inputDir');

  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');

  my ($externalDatabase,$externalDatabaseRls) = $self->getExtDbInfo($test,$extDbRlsSpec);

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--inputDir $workflowDataDir/$inputDir --configFile $workflowDataDir/$configFile --tolerateMissingIds --externalDatabase $externalDatabase --externalDatabaseRls $externalDatabaseRls";


  

    $self->testInputFile('inputDir', "$workflowDataDir/$inputDir");
    $self->testInputFile('configFile', "$workflowDataDir/$configFile");


  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertExpressionProfiles", $args);

}


1;
