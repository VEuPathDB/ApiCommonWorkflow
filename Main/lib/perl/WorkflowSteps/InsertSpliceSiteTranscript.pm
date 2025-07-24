package ApiCommonWorkflow::Main::WorkflowSteps::InsertSpliceSiteTranscript;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $gusConfigFile = $self->getParamValue('gusConfigFile');
  my $project = $self->getParamValue('projectName');

  my $schema = $self->getSharedConfig('webreadySchema');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $mode = $undo ? "delete" : "load";

  my $cmd = "spliceSiteTranscripts.pl --gusConfigFile $workflowDataDir/$gusConfigFile --orgAbbrev $organismAbbrev --mode load --schema $schema --project $project";
  $self->runCmd($test, $cmd);
}

1;
