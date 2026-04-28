/* purpose: remove NCBI gene2pubmed associations from the Literature
   section of gene pages. These rows were loaded by the
   insertPubmedDbXrefs workflow step (since removed in
   ApiCommonWorkflow) and were determined on review to add no useful
   biological insight: the references are generic and apply the same
   paper to large numbers of unrelated genes.

   Scope: only rows whose external_database_release_id maps back to
   ExternalDatabase.name = 'Gene2Pubmed_RSRC'.

   Not affected:
     - curator/Apollo-submitted PMIDs (ExternalDatabase 'PMID' or
       'PubMed', loaded by ISF SpecialCaseQualifierHandlers)
     - any other dbxref class in DbRef/DbRefNAFeature: UniProt,
       EntrezGene, IEDB, OrthoMCL, GO, EC, RefSeq, GenBank,
       organism-specific xrefs.

   Run once per VEuPathDB component schema that loaded gene2pubmed.
   Inspect the pre-delete COUNTs before letting the DELETEs run; if
   numbers look surprising, ROLLBACK instead of letting the COMMIT
   at the bottom fire.
*/

set serveroutput on;
set pagesize 50;

-- pre-delete inventory: which Gene2Pubmed_RSRC releases exist on this
-- instance, and how many rows do they own?
select edr.external_database_release_id,
       edr.version,
       edr.release_date
  from sres.ExternalDatabaseRelease edr,
       sres.ExternalDatabase ed
 where edr.external_database_id = ed.external_database_id
   and ed.name = 'Gene2Pubmed_RSRC'
 order by edr.release_date nulls last;

select count(*) as dbref_rows_to_delete
  from sres.DbRef dr,
       sres.ExternalDatabaseRelease edr,
       sres.ExternalDatabase ed
 where dr.external_database_release_id = edr.external_database_release_id
   and edr.external_database_id = ed.external_database_id
   and ed.name = 'Gene2Pubmed_RSRC';

select count(*) as dbrefnafeat_rows_to_delete
  from dots.DbRefNAFeature dnf
 where dnf.db_ref_id in (
       select dr.db_ref_id
         from sres.DbRef dr,
              sres.ExternalDatabaseRelease edr,
              sres.ExternalDatabase ed
        where dr.external_database_release_id = edr.external_database_release_id
          and edr.external_database_id = ed.external_database_id
          and ed.name = 'Gene2Pubmed_RSRC');

-- sanity check: counts of PMID-like dbref rows grouped by source
-- ExternalDatabase. Curator/Apollo entries should appear under 'PMID'
-- or 'PubMed' and survive this script.
select ed.name, count(*) as dbref_count
  from sres.DbRef dr,
       sres.ExternalDatabaseRelease edr,
       sres.ExternalDatabase ed
 where dr.external_database_release_id = edr.external_database_release_id
   and edr.external_database_id = ed.external_database_id
   and regexp_like(dr.primary_identifier, '^[0-9]+$')
 group by ed.name
 order by 2 desc;

-- ----- DELETES -----
-- join rows first (FK to DbRef), then the orphan DbRef rows.
delete from dots.DbRefNAFeature
 where db_ref_id in (
       select dr.db_ref_id
         from sres.DbRef dr,
              sres.ExternalDatabaseRelease edr,
              sres.ExternalDatabase ed
        where dr.external_database_release_id = edr.external_database_release_id
          and edr.external_database_id = ed.external_database_id
          and ed.name = 'Gene2Pubmed_RSRC');

delete from sres.DbRef
 where external_database_release_id in (
       select edr.external_database_release_id
         from sres.ExternalDatabaseRelease edr,
              sres.ExternalDatabase ed
        where edr.external_database_id = ed.external_database_id
          and ed.name = 'Gene2Pubmed_RSRC');

-- post-delete verification: both should be 0.
select count(*) as remaining_dbrefnafeat_under_gene2pubmed
  from dots.DbRefNAFeature dnf,
       sres.DbRef dr,
       sres.ExternalDatabaseRelease edr,
       sres.ExternalDatabase ed
 where dnf.db_ref_id = dr.db_ref_id
   and dr.external_database_release_id = edr.external_database_release_id
   and edr.external_database_id = ed.external_database_id
   and ed.name = 'Gene2Pubmed_RSRC';

select count(*) as remaining_dbref_under_gene2pubmed
  from sres.DbRef dr,
       sres.ExternalDatabaseRelease edr,
       sres.ExternalDatabase ed
 where dr.external_database_release_id = edr.external_database_release_id
   and edr.external_database_id = ed.external_database_id
   and ed.name = 'Gene2Pubmed_RSRC';

-- spot-check that curator/Apollo PMIDs (under 'PMID' or 'PubMed') survived.
select ed.name, count(*) as surviving_dbref_count
  from sres.DbRef dr,
       sres.ExternalDatabaseRelease edr,
       sres.ExternalDatabase ed
 where dr.external_database_release_id = edr.external_database_release_id
   and edr.external_database_id = ed.external_database_id
   and ed.name in ('PMID', 'PubMed')
 group by ed.name;

commit;

quit;
