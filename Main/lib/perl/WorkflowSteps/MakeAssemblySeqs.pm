package ApiCommonWorkflow::Main::WorkflowSteps::MakeAssemblySeqs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $useTaxonHierarchy = $self->getParamValue('useTaxonHierarchy');

  my $vectorFile = $self->getConfig('vectorFile');
  my $phrapDir = $self->getConfig('phrapDir');

  my $taxonId = $self->getOrganismInfo($test, $organismAbbrev)->getSpeciesTaxonId();
  my $taxonIdList = $self->getTaxonIdList($test, $taxonId, $useTaxonHierarchy);

  my $args = "--taxon_id_list '$taxonIdList' --repeatFile $vectorFile --phrapDir $phrapDir";


  $self->runPlugin($test, $undo, "DoTS::DotsBuild::Plugin::MakeAssemblySequences", $args);

}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	  ['vectorFile', "", ""],
	  ['phrapDir', "", ""],
	 );
}


