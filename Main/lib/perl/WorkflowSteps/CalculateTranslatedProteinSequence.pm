package ApiCommonWorkflow::Main::WorkflowSteps::CalculateTranslatedProteinSequence;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $extDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');
  my $soVersion = $self->getParamValue('soVersion');

  my ($extDbName, $extDbVer) = $self->getExtDbInfo($test,$extDbRlsSpec);

  my $args = "--sqlVerbose --extDbRlsName '$extDbName' --extDbRlsVer '$extDbVer' --soCvsVersion $soVersion";

  $self->runPlugin($test, $undo, "GUS::Supported::Plugin::CalculateTranslatedAASequences", $args);

}

1;

