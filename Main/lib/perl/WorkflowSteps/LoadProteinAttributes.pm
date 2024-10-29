package ApiCommonWorkflow::Main::WorkflowSteps::LoadProteinAttributes;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;



sub run {
  my ($self, $test,$undo) = @_;

  my $extDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');
  my $table = $self->getParamValue('proteinTable');
  my $inputFile = $self->getParamValue('inputFile');

  my ($extDbName, $extDbRlsVer) = $self->getExtDbInfo($test,$extDbRlsSpec);

  my $args = "--extDbRlsName '$extDbName' --extDbRlsVer '$extDbRlsVer' --seqTable $table --inputFile $inputFile";

  $self->runPlugin($test,$undo, "ApiCommonData::Load::Plugin::LoadProteinAttributes",$args);

}


1;
