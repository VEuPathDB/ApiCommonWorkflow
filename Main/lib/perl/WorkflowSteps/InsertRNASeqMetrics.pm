package ApiCommonWorkflow::Main::WorkflowSteps::InsertRNASeqMetrics;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;


  my $experimentDir = $self->getParamValue('experimentDir');
  my $extDbSpec = $self->getParamValue('extDbRlsSpec');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--rnaseqExperimentDirectory $workflowDataDir/$experimentDir --studyExtDbRlsSpec '$extDbSpec'";
  
  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertRNASeqMetrics", $args);
}


1;
