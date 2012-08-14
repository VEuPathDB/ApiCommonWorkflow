package ApiCommonWorkflow::Main::WorkflowSteps::ExtractAssemblySeqs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $useTaxonHierarchy = $self->getParamValue('useTaxonHierarchy');
  my $outputFile = $self->getParamValue('outputFile');

  my $organismInfo = $self->getOrganismInfo($test, $organismAbbrev);
  my $taxonId = $organismInfo->getSpeciesTaxonId();
  my $taxonIdList = $organismInfo->getTaxonIdList($taxonId);

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


sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


