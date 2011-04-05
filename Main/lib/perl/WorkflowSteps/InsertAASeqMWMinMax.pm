package ApiCommonWorkflow::Main::WorkflowSteps::InsertAASeqMWMinMax;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test) = @_;

  my $extDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');
  my $table = $self->getParamValue('table');

  my ($extDbName, $extDbRlsVer) = $self->getExtDbInfo($test,$extDbRlsSpec);

  my $args = "--extDbRlsName '$extDbName' --extDbRlsVer '$extDbRlsVer' --seqTable $table";

  $self->runPlugin($test, "ApiCommonData::Load::Plugin::CalculateAASeqMolWtMinMax",$args);

}

sub getParamsDeclaration {
  return (
	  'genomeExtDbRlsSpec',
	  'table',
	 );
}

sub getConfigDeclaration {
  return (
	 );
}

sub restart {
}

sub undo {

}

sub getDocumentation {
}
