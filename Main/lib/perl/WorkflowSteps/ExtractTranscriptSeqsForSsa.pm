package ApiCommonWorkflow::Main::WorkflowSteps::ExtractTranscriptSeqsForSsa;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $outputFile = $self->getParamValue('outputFile');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $useTopLevel = $self->getBooleanParamValue('useTopLevel');

  my $ncbiTaxonId = $self->getOrganismInfo($test, $organismAbbrev)->getNcbiTaxonId();

  my $dbName = "${organismAbbrev}_primary_genome_RSRC";

  my $dbVersion = $self->getExtDbVersion($test,$dbName);

  my $tuningTablePrefix = $self->getTuningTablePrefix($organismAbbrev, $test);

  my $sql = "select gf.source_id || ':'
                    || substr(ns.source_id, 1, 50) ||':'
                    ||(nl.start_min - 1)||'-'||nl.end_max||'_'||(decode(nl.is_reversed, 1, '-', '+')),
                    snas.sequence
                          from dots.Transcript t, dots.SplicedNaSequence snas,
                               dots.GeneFeature gf, dots.NaLocation nl,
                               dots.NaSequence ns, sres.Taxon ta, sres.SequenceOntology so,
                               sres.externaldatabase db, sres.externaldatabaserelease dbr
                          where gf.na_sequence_id = ns.na_sequence_id
                            and gf.na_feature_id = t.parent_id
                            and t.na_sequence_id = snas.na_sequence_id
                            and gf.sequence_ontology_id = so.sequence_ontology_id
                            and so.term_name != 'repeat_region'
                            and snas.taxon_id = ta.taxon_id
                            and ta.ncbi_tax_id = $ncbiTaxonId
                            and nl.na_feature_id = gf.na_feature_id
                            and db.name = '$dbName'
                            and dbr.version = '$dbVersion'
                            and gf.external_database_release_id = dbr.external_database_release_id";


  if ($useTopLevel) {
    $sql = "SELECT ga.source_id||':'||ga.sequence_id||':'||(ga.start_min - 1)||'-'||ga.end_max||'_'||(decode(ga.is_reversed, 1, '-', '+')), snas.sequence
             FROM dots.transcript t,
                  dots.splicednasequence snas,
                  ApidbTuning.${tuningTablePrefix}geneattributes ga
             WHERE ga.na_feature_id = t.parent_id
              AND t.na_sequence_id = snas.na_sequence_id
              AND ga.so_term_name != 'repeat_region'
              AND ga.ncbi_tax_id = $ncbiTaxonId";

  }

  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {
      if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
      }
      $self->runCmd($test,"gusExtractSequences --outputFile $workflowDataDir/$outputFile --allowEmptyOutput --idSQL \"$sql\" --verbose");
  }
}

1;


