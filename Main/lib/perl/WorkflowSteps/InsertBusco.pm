package ApiCommonWorkflow::Main::WorkflowSteps::InsertBusco;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $genomeFile = $self->getParamValue('genomeResultsFile');
  my $proteomeFile = $self->getParamValue('proteomeResultsFile');
  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');

  my $organismAbbrev = $self->getParamValue("organismAbbrev");
  
  my ($extDbName,$extDbRlsVer) = $self->getExtDbInfo($test,$genomeExtDbRlsSpec);

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--genomeFile $workflowDataDir/$genomeFile --proteinFile $workflowDataDir/$proteomeFile --extDbRlsSpec '$genomeExtDbRlsSpec' --orgAbbrev $organismAbbrev";

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertBUSCO", $args);

}

1;
