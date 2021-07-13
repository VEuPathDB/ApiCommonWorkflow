package ApiCommonWorkflow::Main::WorkflowSteps::MakeAnnotatedCDSDownloadFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub getWebsiteFileCmd {
    my ($self, $downloadFileName, $test) = @_;

    my $organismSource = $self->getParamValue('organismSource');

    my $organismAbbrev = $self->getParamValue('organismAbbrev');
    my $ncbiTaxonId = $self->getOrganismInfo($test,$organismAbbrev)->getNcbiTaxonId();

    my $tuningTablePrefix = $self->getTuningTablePrefix($organismAbbrev, $test);

    my $sql = <<"EOF";
     select gf.source_id
            || decode(gf.is_deprecated, 1, ' | deprecated=true', '')
            || ' | organism=' || replace( gf.organism, ' ', '_')
            || ' | product=' || gf.transcript_product || ' | location='
            || fl.sequence_source_id || ':'
            || least(gf.coding_start,gf.coding_end) ||'-'
            || greatest(gf.coding_start,gf.coding_end)
            || '('|| decode(fl.is_reversed, 1, '-', '+') || ') | length='
            || (abs(gf.coding_start - gf.coding_end) + 1) || ' | sequence_SO=' || soseq.name
            || ' | SO=' || gf.so_term_name || decode(gf.is_deprecated, 1, ' | deprecated=true', '')
            as defline,
           substr(snas.sequence,
                  taaf.translation_start,
                  taaf.translation_stop - taaf.translation_start + 1) as sequence
           from apidb.FeatureLocation fl,
                ApidbTuning.${tuningTablePrefix}TranscriptAttributes gf,
                dots.transcript t, dots.splicednasequence snas, dots.translatedaafeature taaf,
                dots.nasequence ns, sres.ontologyTerm soseq, sres.taxon
      WHERE gf.gene_na_feature_id = t.parent_id
        AND gf.source_id = t.source_id
        AND fl.na_sequence_id = ns.na_sequence_id
        AND t.na_sequence_id = snas.na_sequence_id
        AND gf.gene_na_feature_id = fl.na_feature_id
        AND gf.so_term_name != 'repeat_region'
        AND gf.so_term_name like 'protein_coding%'
        AND taxon.ncbi_tax_id = $ncbiTaxonId 
        AND t.na_feature_id = taaf.na_feature_id
        AND fl.is_top_level = 1
        AND ns.sequence_ontology_id = soseq.ontology_term_id
        AND ns.taxon_id = taxon.taxon_id
     ORDER BY gf.chromosome_order_num, gf.source_id, gf.coding_start
EOF

    my $cmd = "gusExtractSequences --outputFile $downloadFileName  --idSQL \"$sql\"  --verbose ";
    return $cmd;
}
1;
