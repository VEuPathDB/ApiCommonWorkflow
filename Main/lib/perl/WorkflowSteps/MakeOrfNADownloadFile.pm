package ApiCommonWorkflow::Main::WorkflowSteps::MakeOrfNADownloadFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;

sub getWebsiteFileCmd {
    my ($self, $downloadFileName, $test) = @_;

  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $length = $self->getParamValue('minOrfLength');

  my $taxonId = $self->getOrganismInfo($test, $organismAbbrev)->getTaxonId();
  my $tuningTablePrefix = $self->getTuningTablePrefix($organismAbbrev, $test);


  my $sql = <<"EOF";
    SELECT
       m.source_id
        ||' | organism='||
       replace(tn.name, ' ', '_')
        ||' | location='||
       fl.sequence_source_id
        ||':'||
       fl.start_min
        ||'-'||
       fl.end_max
        ||'('||
       decode(fl.is_reversed, 1, '-', '+')
        ||') | length='||
       (fl.end_max - fl.start_min + 1 )  || ' | sequence_SO=' || soseq.name as defline,
       decode(fl.is_reversed,1, apidb.reverse_complement_clob(SUBSTR(enas.sequence,fl.start_min,fl.end_max - fl.start_min +1)),SUBSTR(enas.sequence,fl.start_min,fl.end_max - fl.start_min + 1))
       FROM dots.miscellaneous m,
            dots.translatedaafeature taaf,
            dots.translatedaasequence taas,
            sres.taxonname tn,
            sres.ontologyTerm so,
            sres.ontologyTerm soseq,
            ApidbTuning.${tuningTablePrefix}FeatureLocation fl,
            dots.nasequence enas
      WHERE m.na_feature_id = taaf.na_feature_id
        AND taaf.aa_sequence_id = taas.aa_sequence_id
        AND m.na_feature_id = fl.na_feature_id
        AND fl.is_top_level = 1
        AND enas.na_sequence_id = fl.na_sequence_id 
        AND enas.taxon_id = $taxonId
        AND enas.taxon_id = tn.taxon_id
        AND enas.sequence_ontology_id = soseq.ontology_term_id
        AND tn.name_class = 'scientific name'
        AND m.sequence_ontology_id = so.ontology_term_id
        AND so.name = 'ORF'
        AND taas.length >= $length
EOF

   my $cmd = <<"EOF";
      gusExtractSequences --outputFile $downloadFileName \\
      --idSQL \"$sql\" \\
      --verbose  
EOF
    return $cmd;
}

