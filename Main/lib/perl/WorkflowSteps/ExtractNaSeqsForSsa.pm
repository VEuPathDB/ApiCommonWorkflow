package ApiCommonWorkflow::Main::WorkflowSteps::ExtractNaSeqsForSsa;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $outputFile = $self->getParamValue('outputFile');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $useTopLevel = $self->getBooleanParamValue('useTopLevel');
  my $gusConfigFile = $self->getParamValue('gusConfigFile');
  $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";

  my $ncbiTaxonId = $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getNcbiTaxonId();
  my $tuningTablePrefix = $self->getTuningTablePrefix($test, $organismAbbrev, $gusConfigFile);

  my $sql = "select ns.source_id||':1-'||ns.length||'_strand=+', ns.sequence
             from dots.ExternalNaSequence ns, sres.Taxon t, sres.SequenceOntology so
             where ns.taxon_id = t.taxon_id
               and t.ncbi_tax_id = $ncbiTaxonId
               and ns.sequence_ontology_id = so.sequence_ontology_id
               and so.term_name in ('mitochondrial_chromosome','contig','chromosome','apicoplast_chromosome','supercontig')";

  if ($useTopLevel) {
    $sql = "select sa.source_id||':1-'||ns.length||'_strand=+', ns.sequence
            from ApidbTuning.${tuningTablePrefix}GenomicSeqAttributes sa, dots.nasequence ns
            where sa.is_top_level = 1
            and sa.na_sequence_id = ns.na_sequence_id
            and sa.NCBI_TAX_ID = $ncbiTaxonId";
  }




  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile.multiLine");
  } else {
      if ($test) {
        $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
      }
      $self->runCmd($test,"gusExtractSequences --outputFile $workflowDataDir/$outputFile.multiLine --idSQL \"$sql\" --verbose");
      $self->runCmd($test,"modify_fa_to_have_seq_on_one_line.pl $workflowDataDir/$outputFile.multiLine >$workflowDataDir/$outputFile");
  }
}

1;

