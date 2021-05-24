package ApiCommonWorkflow::Main::WorkflowSteps::InsertPlatformReporter;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $fastaFile = $self->getParamValue('fastaFile');

  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');

  my $platformName = $self->getParamValue('platformName');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--inputFile $workflowDataDir/$fastaFile  --extDbSpec '$extDbRlsSpec' --arrayDesignName '$platformName'";

  $self->testInputFile('inputDir', "$workflowDataDir/$fastaFile") if $test;

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertPlatformReporter", $args);
}

1;
