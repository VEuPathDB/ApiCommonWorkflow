package ApiCommonWorkflow::Main::WorkflowSteps::MakeOrfDownloadFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;


sub getWebsiteFileCmd {
  my ($self, $downloadFileName, $test) = @_;
  
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $length = $self->getParamValue('minOrfLength');
  my $gusConfigFile = $self->getParamValue('gusConfigFile');
  $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";

  my $taxonId = $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getTaxonId();
  my $tuningTablePrefix = $self->getTuningTablePrefix($test, $organismAbbrev, $gusConfigFile);

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
       taas.length || ' | sequence_SO=' || soseq.name as defline,
       taas.sequence
       FROM dots.miscellaneous m,
            dots.translatedaafeature taaf,
            dots.translatedaasequence taas,
            sres.taxonname tn,
            sres.ontologyTerm so,
            sres.ontologyTerm soseq,
            apidb.FeatureLocation fl,
            ( SELECT na_sequence_id, taxon_id, sequence_ontology_id, chromosome_order_num 
              FROM  dots.virtualsequence
              UNION
              SELECT na_sequence_id, taxon_id, sequence_ontology_id, chromosome_order_num 
              FROM  dots.externalnasequence
            ) enas 
            --dots.externalnasequence enas
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
     ORDER BY enas.chromosome_order_num, taaf.source_id, fl.start_min
EOF

    my $cmd = <<"EOF";
      gusExtractSequences --outputFile $downloadFileName \\
      --idSQL \"$sql\" \\
      --verbose 
EOF
    return $cmd;
}

