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
  my $gusConfigFile = $self->getParamValue('gusConfigFile');
  $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";

  my $organismInfo = $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile);
  #my $taxonId = $organismInfo->getSpeciesTaxonId();
  #my $taxonIdList = $organismInfo->getTaxonIdList($taxonId);
  my $speciesNcbiTaxonId = $self->getParamValue('speciesNcbiTaxonId');
  my $taxonId = $self->getTaxonIdFromNcbiTaxId($test,$speciesNcbiTaxonId);
  my $taxonIdList = $organismInfo->getTaxonIdList($taxonId);

  my $soExtDbName = $self->getSharedConfig("sequenceOntologyExtDbName");

  # TODO:  Pass in SO external database name|version
  my $args = "--taxon_id_list '$taxonIdList' --repeatFile $vectorFile --phrapDir $phrapDir --soExtDbSpec '$soExtDbName|%'";


  $self->runPlugin($test, $undo, "DoTS::DotsBuild::Plugin::MakeAssemblySequences", $args);

}

1;
