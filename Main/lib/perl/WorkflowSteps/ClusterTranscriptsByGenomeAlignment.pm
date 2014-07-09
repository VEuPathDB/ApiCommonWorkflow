package ApiCommonWorkflow::Main::WorkflowSteps::ClusterTranscriptsByGenomeAlignment;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $outputFile = $self->getParamValue('outputFile');
  my $ncbiTaxonId = $self->getParamValue('parentNcbiTaxonId');
  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');
  my $maxIntronSize = $self->getParamValue('distanceBetweenStartsForAlignmentsInSameCluster');

  my $taxonId = $self->getTaxonIdFromNcbiTaxId($test,$ncbiTaxonId);
  my $targetDbRlsId = $self->getExtDbRlsId($test, $genomeExtDbRlsSpec);

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--taxon_id $taxonId --target_table_name ExternalNASequence --mixedESTs --target_db_rel_id $targetDbRlsId --out $workflowDataDir/$outputFile --sort 1 --distanceBetweenStarts $maxIntronSize";

  #plugin does not modify db, only makes output file

  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {
      if ($test) {
	  $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
      }
      $self->runPlugin($test,0, "DoTS::DotsBuild::Plugin::ClusterByGenome", $args);
  }
}

1;
