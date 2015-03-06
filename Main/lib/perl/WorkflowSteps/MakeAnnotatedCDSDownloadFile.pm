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
            || ' | product=' || product_name.product || ' | location='
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
           from ApidbTuning.${tuningTablePrefix}FeatureLocation fl,
                ApidbTuning.${tuningTablePrefix}TranscriptAttributes gf,
                dots.transcript t, dots.splicednasequence snas, dots.translatedaafeature taaf,
                dots.nasequence ns, sres.ontologyTerm soseq, sres.taxon,
                (select gf.na_feature_id,
                        substr(coalesce(preferred_product.product, any_product.product, gf.product, 'unspecified product'),
                               1, 300)
                        || case
                             when (coalesce(preferred_name.name, any_name.name) is not null)
                             then ' (' || coalesce(preferred_name.name, any_name.name) || ')'
                             else ''
                            end
                        as product
                 from dots.GeneFeature gf,
                      (select na_feature_id, max(product) as product
                       from apidb.GeneFeatureProduct
                       where is_preferred = 1
                       group by na_feature_id
                      ) preferred_product,
                      (select na_feature_id, max(product) as product
                       from apidb.GeneFeatureProduct
                       group by na_feature_id
                      ) any_product,
                      (select na_feature_id, max(name) as name
                       from apidb.GeneFeatureName
                       where is_preferred = 1
                       group by na_feature_id
                      ) preferred_name,
                      (select na_feature_id, max(name) as name
                       from apidb.GeneFeatureName
                       group by na_feature_id
                      ) any_name
                 where gf.na_feature_id = preferred_product.na_feature_id(+)
                   and gf.na_feature_id = any_product.na_feature_id(+)
                   and gf.na_feature_id = preferred_name.na_feature_id(+)
                   and gf.na_feature_id = any_name.na_feature_id(+)
                ) product_name
      WHERE gf.na_feature_id = t.parent_id
        AND fl.na_sequence_id = ns.na_sequence_id
        AND t.na_sequence_id = snas.na_sequence_id
        AND gf.na_feature_id = fl.na_feature_id
        AND gf.so_term_name != 'repeat_region'
        AND gf.so_term_name = 'protein_coding'
        AND taxon.ncbi_tax_id = $ncbiTaxonId 
        AND t.na_feature_id = taaf.na_feature_id
        AND fl.is_top_level = 1
        AND ns.sequence_ontology_id = soseq.ontology_term_id
        AND ns.taxon_id = taxon.taxon_id
        and gf.na_feature_id = product_name.na_feature_id
EOF

    my $cmd = "gusExtractSequences --outputFile $downloadFileName  --idSQL \"$sql\"  --verbose";
    return $cmd;
}
1;
