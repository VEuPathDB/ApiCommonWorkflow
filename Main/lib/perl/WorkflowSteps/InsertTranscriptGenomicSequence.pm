package ApiCommonWorkflow::Main::WorkflowSteps::InsertTranscriptGenomicSequence;

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

  my $cmd = "transcriptGenomicSequenceTable --gusConfigFile $workflowDataDir/$gusConfigFile --mode $mode --schema $schema --project $project";

  $cmd .= " --orgAbbrev $organismAbbrev" if ($organismAbbrev);

  $self->runCmd($test, $cmd);
}

1;
