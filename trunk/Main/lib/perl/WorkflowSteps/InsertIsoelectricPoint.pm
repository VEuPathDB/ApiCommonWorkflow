package ApiCommonWorkflow::Main::WorkflowSteps::InsertIsoelectricPoint;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test) = @_;

  my $extDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');
  my $table = $self->getParamValue('table');

  my ($extDbName, $extDbRlsVer) = $self->getExtDbInfo($test,$extDbRlsSpec);

  my $args = "--extDbRlsName '$extDbName' --extDbRlsVer '$extDbRlsVer' --seqTable $table";

  $self->runPlugin($test,0, "ApiCommonData::Load::Plugin::CalculateAASequenceIsoelectricPoint",$args);

}

sub getParamsDeclaration {
  return (
     'genomeExtDbRlsSpec',
     'table',
    );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


