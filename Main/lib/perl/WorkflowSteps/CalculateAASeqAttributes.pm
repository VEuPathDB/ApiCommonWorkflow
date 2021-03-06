package ApiCommonWorkflow::Main::WorkflowSteps::CalculateAASeqAttributes;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;



sub run {
  my ($self, $test,$undo) = @_;

  my $extDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');
  my $table = $self->getParamValue('table');
  my $idSql = $self->getParamValue('idSql');

  my ($extDbName, $extDbRlsVer) = $self->getExtDbInfo($test,$extDbRlsSpec);

  my $args = "--extDbRlsName '$extDbName' --extDbRlsVer '$extDbRlsVer' --seqTable $table";

  $args .= " --idSql \"$idSql\"" if $idSql;

  $self->runPlugin($test,$undo, "ApiCommonData::Load::Plugin::CalculateAASeqAttributes",$args);

}


1;
