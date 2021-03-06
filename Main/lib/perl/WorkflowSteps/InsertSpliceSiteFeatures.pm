package ApiCommonWorkflow::Main::WorkflowSteps::InsertSpliceSiteFeatures;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $configFile = $self->getParamValue('configFile');

  my $inputDir = $self->getParamValue('inputDir');

  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');

  my $type = $self->getParamValue('type');

  my ($extDbName,$extDbVer) = split(/\|/,$extDbRlsSpec);

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--dirPath $workflowDataDir/$inputDir --dirPath $workflowDataDir/$inputDir --configFile $workflowDataDir/$configFile  --extDbName $extDbName --extDbVer $extDbVer --type '$type'";


  $self->testInputFile('inputDir', "$workflowDataDir/$inputDir");
  $self->testInputFile('configFile', "$workflowDataDir/$configFile");

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertSpliceSiteFeatures", $args);

}

1;
