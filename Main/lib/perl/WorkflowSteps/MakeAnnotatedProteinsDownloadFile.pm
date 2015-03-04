package ApiCommonWorkflow::Main::WorkflowSteps::MakeAnnotatedProteinsDownloadFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub getWebsiteFileCmd {
    my ($self, $downloadFileName, $test) = @_;


    my $organismSource = $self->getParamValue('organismSource');
    my $organismAbbrev = $self->getParamValue('organismAbbrev');

    my $ncbiTaxonId = $self->getOrganismInfo($test, $organismAbbrev)->getNcbiTaxonId();
    my $tuningTablePrefix = $self->getTuningTablePrefix($organismAbbrev, $test);

  my $sql = <<"EOF";
     select gf.source_id
            || decode(deprecated.is_deprecated, 1, ' | deprecated=true', '')
            || ' | organism=' || replace( tn.name, ' ', '_')
            || ' | product=' || product_name.product || ' | location='
            || ns.source_id || ':'
--            || least(gf.coding_start,gf.coding_end) ||'-'
--            || greatest(gf.coding_start,gf.coding_end)
            || least(fl.start_min,fl.end_max) ||'-'
            || greatest(fl.start_min, fl.end_max)
            || '('|| decode(fl.is_reversed, 1, '-', '+') || ') | length='
--            || (abs(gf.coding_start - gf.coding_end) + 1) || ' | sequence_SO=' || soseq.name
            || (abs(fl.start_min - fl.end_max) + 1) || ' | sequence_SO=' || soseq.name
            || ' | SO=' || so.name || decode(deprecated.is_deprecated, 1, ' | deprecated=true', '')
            as defline,
           substr(snas.sequence,
                  taaf.translation_start,
                  taaf.translation_stop - taaf.translation_start + 1) as sequence
           from dots.NaLocation fl, dots.geneFeature gf, dots.transcript t, sres.TaxonName tn, sres.Taxon,
                dots.splicednasequence snas, dots.translatedaafeature taaf,
                dots.nasequence ns, sres.ontologyTerm soseq, sres.ontologyTerm so,
                (select distinct drnf.na_feature_id, 1 as is_deprecated
                 from dots.DbRefNaFeature drnf, sres.DbRef dr, sres.ExternalDatabaseRelease edr, sres.ExternalDatabase ed
                 where drnf.db_ref_id = dr.db_ref_id
                   and dr.external_database_release_id = edr.external_database_release_id
                   and edr.external_database_id = ed.external_database_id
                   and ed.name = 'gassAWB_dbxref_gene2Deprecated_RSRC') deprecated,
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
        AND gf.na_sequence_id = ns.na_sequence_id
        AND t.na_sequence_id = snas.na_sequence_id
        AND gf.na_feature_id = fl.na_feature_id
        AND so.name != 'repeat_region'
        AND so.name = 'protein_coding'
        AND taxon.ncbi_tax_id = $ncbiTaxonId 
        AND t.na_feature_id = taaf.na_feature_id
        and gf.na_feature_id = deprecated.na_feature_id(+)
        AND gf.sequence_ontology_id = so.ontology_term_id
        AND ns.sequence_ontology_id = soseq.ontology_term_id
        and ns.taxon_id = tn.taxon_id
        and ns.taxon_id = taxon.taxon_id
        and tn.name_class = 'scientific name'
        and gf.na_feature_id = product_name.na_feature_id
EOF


  my $cmd = " gusExtractSequences --outputFile $downloadFileName  --idSQL \"$sql\"";
    return $cmd;
}

1;
