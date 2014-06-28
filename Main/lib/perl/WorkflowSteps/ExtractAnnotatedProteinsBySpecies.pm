package ApiCommonWorkflow::Main::WorkflowSteps::ExtractAnnotatedProteinsBySpecies;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');
  my $ncbiTaxonId = $self->getParamValue('ncbiTaxonId');
  my $outputFile = $self->getParamValue('outputFile');

  my $genomeDbRlsId = $self->getExtDbRlsId($test, $genomeExtDbRlsSpec);
  my $taxonId = $self->getTaxonIdFromNcbiTaxId($test,$ncbiTaxonId);

  my $sql = "SELECT tx.source_id,g.product,
                    'length='||length(t.sequence),t.sequence
               FROM dots.NASequence x,
                    dots.transcript tx,
                    dots.nafeature f,
                    dots.genefeature g,
                    dots.translatedaafeature a,
                    dots.translatedaasequence t
              WHERE x.taxon_id = $taxonId
                AND x.external_database_release_id = $genomeDbRlsId
                AND tx.parent_id = g.na_feature_id
                AND x.na_sequence_id = f.na_sequence_id 
                AND f.na_feature_id = a.na_feature_id
                AND a.aa_sequence_id = t.aa_sequence_id
                AND a.na_feature_id = tx.na_feature_id
                AND t.length > 9";

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "gusExtractSequences --outputFile $workflowDataDir/$outputFile --idSQL \"$sql\" --verbose";



  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile.d*");
  } else {  
      if ($test) {
	  $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
      }
      $self->runCmd($test,$cmd);
  }
}

1;

