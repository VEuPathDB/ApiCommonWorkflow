package ApiCommonWorkflow::Main::WorkflowSteps::ExtractAssemblySeqs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $useTaxonHierarchy = $self->getParamValue('useTaxonHierarchy');
  my $outputFile = $self->getParamValue('outputFile');
  my $gusConfigFile = $self->getParamValue('gusConfigFile');
  $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";

  my $organismInfo = $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile);
  my $speciesNcbiTaxonId = $self->getParamValue('speciesNcbiTaxonId');
  my $taxonIdList = $organismInfo->getSubTaxaListFromNcbiTaxonId($speciesNcbiTaxonId, $gusConfigFile);

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--taxon_id_list '$taxonIdList' --outputfile $workflowDataDir/$outputFile --extractonly";

  if ($test) {
      $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
  }

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } 
  $self->runPlugin($test, $undo, "DoTS::DotsBuild::Plugin::ExtractAndBlockAssemblySequences", $args);
}


1;


