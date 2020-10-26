package ApiCommonWorkflow::Main::WorkflowSteps::InsertRnaSeqPatch;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $configFile = $self->getParamValue('configFile');

  my $inputDir = $self->getParamValue('inputDir');

  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');

  my $studyName = $self->getParamValue('studyName');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--inputDir $workflowDataDir/$inputDir --configFile $workflowDataDir/$configFile --extDbSpec '$extDbRlsSpec' --studyName '$studyName'";

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertRnaSeqPatch", $args);

}


1;
