package ApiCommonWorkflow::Main::WorkflowSteps::LoadGeneGenomicSequenceByQuery;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

#The step calls ApiCommonData::Load::Plugin::InsertGeneGenomicSequence to populate a new table: ApiDB.GeneGenomicSequence_Split. This table speed up live site performance.It pre-computes values made now by the slow GeneModel wdk table query, which is slowing down the gene pages.

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
