package ApiCommonWorkflow::Main::WorkflowSteps::LoadGeneGenomicSequenceByQuery;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;



sub run {
  my ($self, $test,$undo) = @_;

  my $extDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpecList');

  my @extDbRlsSpecList = split(/,/, $extDbRlsSpec);

  my $dbRlsIds;

  foreach my $db (@extDbRlsSpecList){

     $dbRlsIds .= $self->getExtDbRlsId($test, $db).",";

  }

  $dbRlsIds =~ s/(,)$//g;

  my $args = "--dbRlsIds $dbRlsIds";

  $self->runPlugin($test,$undo, "ApiCommonData::Load::Plugin::InsertGeneGenomicSequence", $args);

}

sub getParamsDeclaration {
  return (
	  'extDbRlsSpec',
	 );
}

sub getConfigDeclaration {
  return (

	 );
}
