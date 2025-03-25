package ApiCommonWorkflow::Main::WorkflowSteps::ExtractAnnotatedProteinsBySpecies;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');
  my $ncbiTaxonId = $self->getParamValue('ncbiTaxonId');
  my $outputFile = $self->getParamValue('outputFile');
  my $gusConfigFile = $self->getGusConfigFile();

  my $genomeDbRlsId = $self->getExtDbRlsId($test, $genomeExtDbRlsSpec);
  my $taxonId = $self->getTaxonIdFromNcbiTaxId($test,$ncbiTaxonId);

  my $sql = "SELECT tas.source_id
                    , 'length='||length(tas.sequence) as length
                    , 'transcript='||tx.source_id as transcript
                    , 'gene='||g.source_id as gene
                    ,tas.sequence
             FROM dots.NASequence x,
                  dots.transcript tx,
                  dots.nafeature f,
                  dots.genefeature g,
                  dots.translatedaafeature a,
                  dots.translatedaasequence tas
             WHERE x.taxon_id = $taxonId
                  AND x.external_database_release_id = $genomeDbRlsId
                  AND tx.parent_id = g.na_feature_id
                  AND x.na_sequence_id = f.na_sequence_id
                  AND f.na_feature_id = a.na_feature_id
                  AND a.aa_sequence_id = tas.aa_sequence_id
                  AND a.na_feature_id = tx.na_feature_id
                  AND tas.length > 9";

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "gusExtractSequences --gusConfigFile $gusConfigFile --outputFile $workflowDataDir/$outputFile --idSQL \"$sql\" --verbose";

  my $cmd_replace = "cat $workflowDataDir/$outputFile | perl -pe 'unless (/^>/){s/\\*/X/g;}' > $workflowDataDir/$outputFile.NoAsterisks";

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile.NoAsterisks");
  } else {
    if ($test) {
      $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
    }
    $self->runCmd($test,$cmd);
    $self->runCmd($test,$cmd_replace);
  }
}

1;

