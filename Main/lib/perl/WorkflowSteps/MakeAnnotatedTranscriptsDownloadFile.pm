package ApiCommonWorkflow::Main::WorkflowSteps::MakeAnnotatedTranscriptsDownloadFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WebsiteFileMaker;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub getWebsiteFileCmd {
  my ($self, $downloadFileName, $test) = @_;

  # get parameters
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $organismSource = $self->getParamValue('organismSource');

  my $ncbiTaxonId = $self->getOrganismInfo($test, $organismAbbrev)->getNcbiTaxonId();

  my $tuningTablePrefix = $self->getTuningTablePrefix($organismAbbrev, $test);
 
=comment out in gus4, refs #21487
  my $sql = <<"EOF";
     SELECT t.source_id || ' | gene=' || gf.source_id
                || decode(deprecated.is_deprecated, 1, ' | deprecated=true', '')
                ||' | organism='||
            replace( tn.name, ' ', '_')
                ||' | product='||
            product_name.product
                ||' | location='||
            ns.source_id
                ||':'||
            fl.start_min
                ||'-'||
            fl.end_max
                ||'('||
            decode(fl.is_reversed, 1, '-', '+')
                ||') | length='||
            snas.length || ' | sequence_SO=' || soseq.name
                || ' | SO=' || so.name || decode(deprecated.is_deprecated, 1, ' | deprecated=true', '')
            as defline,
            snas.sequence
           FROM dots.GeneFeature gf,
                dots.transcript t,
                dots.splicednasequence snas, dots.NaLocation fl,
                dots.externalnasequence ns,
                sres.ontologyTerm soseq, sres.ontologyTerm so, sres.taxonName tn, sres.Taxon,
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
                ) product_name,
                (select distinct drnf.na_feature_id, 1 as is_deprecated
                 from dots.DbRefNaFeature drnf, sres.DbRef dr, sres.ExternalDatabaseRelease edr, sres.ExternalDatabase ed
                 where drnf.db_ref_id = dr.db_ref_id
                   and dr.external_database_release_id = edr.external_database_release_id
                   and edr.external_database_id = ed.external_database_id
                   and ed.name = 'gassAWB_dbxref_gene2Deprecated_RSRC') deprecated
      WHERE gf.na_feature_id = t.parent_id
        and gf.na_feature_id = deprecated.na_feature_id(+)
        AND gf.sequence_ontology_id = so.ontology_term_id
        AND ns.na_sequence_id = gf.na_sequence_id
        AND t.na_sequence_id = snas.na_sequence_id
        AND gf.na_feature_id = fl.na_feature_id
        AND so.name != 'repeat_region'
        AND ns.taxon_id = taxon.taxon_id
        AND taxon.ncbi_tax_id = $ncbiTaxonId
--        AND fl.is_top_level = 1
        AND ns.sequence_ontology_id = soseq.ontology_term_id
        AND ns.taxon_id = tn.taxon_id
        AND tn.name_class = 'scientific name'
        AND gf.na_feature_id = product_name.na_feature_id
      ORDER BY ns.chromosome_order_num, t.source_id, gf.source_id, fl.start_min
EOF
=cut

  my $sql = <<EOF;
SELECT t.source_id || ' | gene=' || gene_source_id || decode(is_deprecated, 1, ' | deprecated=true', '')
  || ' | organism=' || replace(organism, ' ', '_') || ' | gene_product=' || gene_product || ' | transcript_product=' || transcript_product
  || ' | location=' || sequence_id || ':' || coding_start || '-' || coding_end
  || '(' || decode(is_reversed, 1, '-', '+') || ')' 
  || ' | length=' || t.length 
  || ' | sequence_SO=' || soseq.name || ' | SO=' || so_term_name || decode(is_deprecated, 1, ' | deprecated=true', '')
  as defline,
  ts.SEQUENCE
FROM ApidbTuning.${tuningTablePrefix}TranscriptAttributes t, ApidbTuning.${tuningTablePrefix}TranscriptSequence ts,
  DOTS.NASEQUENCE ns, sres.ontologyTerm soseq
WHERE t.source_id = ts.SOURCE_ID
  AND ns.SOURCE_ID = t.SEQUENCE_ID
  AND ns.sequence_ontology_id = soseq.ontology_term_id
  AND t.ncbi_tax_id = $ncbiTaxonId
ORDER BY t.chromosome_order_num, t.SEQUENCE_ID,t.source_id, t.coding_start
EOF

  my $cmd = "gusExtractSequences --outputFile $downloadFileName  --idSQL \"$sql\" --verbose && gzip $downloadFileName";
}

1;
