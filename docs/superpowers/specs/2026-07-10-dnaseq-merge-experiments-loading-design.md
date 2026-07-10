# DNASeq mergeExperiments: wiring, cache, and variation loading

**Date:** 2026-07-10
**Branch:** dnaseq-merge-experiments (current feature branch)
**Status:** Design — awaiting user review

## Problem

`dnaseq.xml` has a commented-out `runDnaSeqMergeExperiments` subgraph (a stub). The subgraph
XML (`dnaSeqMergeExperiments.xml`) and its step classes exist, but:

1. The generated nextflow config no longer matches the `dnaseq-nextflow` `mergeExperiments`
   entry's params — it carries obsolete params and is missing a now-required one (`ploidy`).
2. The `transcript_product.dat` cache (a computed lookup that speeds subsequent runs) is not
   persisted across workflow runs.
3. The merge output is never loaded into the database. The `InsertVariationFeatures` plugin
   (ApiCommonData) exists to load it but is not wired in.
4. No ExternalDatabaseRelease exists for the loaded variations.

## Authoritative param contract

Source of truth for the `mergeExperiments` entry is `dnaseq-nextflow`:
- `nextflow.config` `mergeExperiments` profile (lines 53-66)
- params referenced in `workflows/mergeExperiments.nf` and `modules/mergeExperiments.nf`

Params the merge entry actually consumes:
`vcfFiles`, `coverageFiles`, `indelsFiles`, `relativeConsensusFilePattern`, `cacheFile`,
`outputDir`, `genomeFastaFile`, `gtfFile`, `undoneStrains`, `reference_strain`, **`ploidy`**.

`ploidy` is referenced at `modules/mergeExperiments.nf:195` inside `processSeqVars`, which the
`me` (mergeExperiments) workflow calls at `workflows/mergeExperiments.nf:37`. It is NOT in the
`mergeExperiments` config profile — a real run today would pass `--ploidy null`.

## Design

### A. Reconcile the merge nextflow config generator

File: `Main/lib/perl/WorkflowSteps/MakeDnaSeqMergeExperimentsNextflowConfig.pm`

**Remove these params (unused by the merge entry):** `cacheFileDir`, `organism_abbrev`,
`varscan_directory`, `varscanFilePath`, `webServicesDir`, `extDbRlsSpec`.

**Keep:** `outputDir`, `cacheFile`, `undoneStrains`, `reference_strain` (still DB-queried via
`REF_STRAIN_ABBREV`), `genomeFastaFile`, `gtfFile`, `relativeConsensusFilePattern`, `vcfFiles`,
`indelsFiles`, `coverageFiles`.

**Add `ploidy`.** Ploidy is not a first-class organism attribute in the DB and per-experiment
ploidy is only visible inside the dataset template scope. Workaround: read ploidy from the
per-experiment generated configs and validate consistency.

- New param `experimentConfigGlob` = `$$dataDir$$/*/dnaseqNextflow/analysisDir/nextflow.config`
  (one level up from the `results` dirs the merge already globs).
- The step globs those files, parses `^\s*ploidy\s*=\s*(\S+)` from each
  (format written by `MakeDnaSeqNextflowConfig.pm:71`: `  ploidy                   = <value>`).
- **Die** if zero configs found, if any config lacks a ploidy line, or if values disagree.
- Write the single agreed value into the merge config as `ploidy = N`.
- Add a prominent comment flagging this as deliberate technical debt: ploidy belongs in
  `apidb.organism`; this couples the merge step to a sibling step's output file format.

Corresponding cleanup in `Main/lib/xml/workflow/dnaSeqMergeExperiments.xml`: drop the obsolete
`<param>`/`<paramValue>` entries (`varscanDirectory`, `varscanFilePath`, `webServicesDir`,
`extDbRlsSpec`); `cacheFile` becomes an absolute persistent path passed from the parent
(see B), not a bare filename.

### B. transcript_product.dat cache lifecycle

Persistent cache path (outside the ephemeral `_mergeExperiments` dir so undo/re-run does not
wipe it): `$$dataDir$$/$$organismAbbrev$$_transcript_product.cache.dat`
where `dataDir = $$parentDataDir$$/dnaseq`.

Steps in `dnaseq.xml`:
1. **`touchTranscriptProductCache`** (`ReFlow`/`ApiCommonWorkflow` `TouchFile`), depends on
   `makeDataDir`. `touch` does not truncate, so a cache persisted from a prior run survives;
   first run gets an empty file. Runs before the merge subgraph.
2. Pass the cache path to the subgraph as `cacheFile`; the config generator makes it absolute
   and emits it as `--cache_file`.
3. **`copyTranscriptProductCache`** (`CopyDataDirFile`), `fromFile =
   <mergeOutputDir>/transcript_product.dat`, `toFile = <cache>`, depends on the merge subgraph.

`<mergeOutputDir>` = `$$dataDir$$/$$organismAbbrev$$_mergeExperiments/output`.

### C. Load variations via the plugin — one new step class

File: `Main/lib/perl/WorkflowSteps/InsertVariationFeatures.pm` (new; mirrors
`InsertStudyResults.pm`).

- Params: `inputDir`, `extDbRlsSpec`, `organismAbbrev`, optional `targetSchema`.
- Builds `--inputDir <workflowDataDir>/<inputDir> --extDbRlsSpec '<spec>' --organismAbbrev
  '<abbrev>'` (+ `--targetSchema` if given) and calls
  `runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertVariationFeatures", $args)`.
- Arg names match the plugin's `getArgsDeclaration` (`inputDir`, `extDbRlsSpec`,
  `organismAbbrev`, `targetSchema`).

Wired into `dnaseq.xml` as `insertVariationFeatures` (`stepLoadTypes="plugin"`),
`inputDir = <mergeOutputDir>`, `organismAbbrev = $$organismAbbrev$$`,
`extDbRlsSpec = $$organismAbbrev$$_dnaSeqVariations|do_not_care`. Depends on the merge subgraph
AND the ext-db step (D).

The plugin consumes `variationFeature.dat`, `transcript_product.dat`, `snpeff.dat` from the
merge output dir. `allele.dat` / `sample.dat` are out of scope (loaded elsewhere).

### E. Publish merge outputs to webservices — one new step class

The website reads dnaseq artifacts from `<websiteFilesDir>/<relativeWebServicesDir>/
<organismNameForFiles>/dnaseq/` (bigwigs already land at `dnaseq/bigwig/...` via
`CopyDnaseqBigwigToWebSvc`). Publish the merge outputs into that same `dnaseq/` base with one new
step class `CopyDnaSeqMergeResultsToWebServices.pm` (mirrors `CopyDnaseqBigwigToWebSvc`):

- `merged.ann.vcf.gz` + `merged.ann.vcf.gz.tbi` → `dnaseq/vcf/`
- `hsss_readFreqN` dirs → `dnaseq/readFreqN` (**strip the `hsss_` prefix** to match the naming the
  old `MakeHighSpeedSearchFiles` generator produced, which the site's high-speed-search reader
  expects).

Params: `copyFromDir` (= `<mergeOutputDir>`), `organismAbbrev`, `relativeDir`
(= `$$relativeWebServicesDir$$`), `gusConfigFile`. Undo removes `dnaseq/vcf` and the `readFreqN`
dirs only (never the whole `dnaseq/` dir — bigwigs live there). Copies are restart-safe
(`rm -rf <target>` before each dir copy). Wired into `dnaseq.xml` as
`copyMergeResultsToWebServices`, depends on the merge subgraph.

### D. External database + release — reuse existing step

New step instance in `dnaseq.xml`, `createDnaSeqVariationExtDbRls`, using the existing
`CreateExtDbAndDbRls` step class (runs `GUS::Supported::Plugin::InsertExternalDatabase` then
`InsertExternalDatabaseRls`, with undo). No new Perl.

- `extDbRlsSpec = $$organismAbbrev$$_dnaSeqVariations|do_not_care`
- `gusConfigFile = $$gusConfigFile$$`
- depends on `makeDataDir`.

### Dependency order in dnaseq.xml

```
makeDataDir
  ├── touchTranscriptProductCache ─────────────┐
  ├── createDnaSeqVariationExtDbRls ───────────┐│
  └── (existing: makeGtfFile, makeGeneFootprintFile,
        retrieveGeneCNVAndPloidyQueries, dataset template,
        makeMergeExperimentsDataDir)
                    │
        runDnaSeqMergeExperiments (subgraph, existing;
          receives cacheFile = <cache path>)
                    │
        ┌───────────┼───────────────────────┐
 insertVariationFeatures  copyTranscriptProductCache  copyMergeResultsToWebServices
 (also depends on
  createDnaSeqVariationExtDbRls)
```

`insertVariationFeatures`, `copyTranscriptProductCache`, and `copyMergeResultsToWebServices` all
read the merge output; order between them is irrelevant (plugin reads output/*.dat; cache copy
reads output/transcript_product.dat → cache; webservices copy reads output/merged.ann.vcf.gz* and
output/hsss_readFreq*). No conflict.

## Scope of changes

| File | Change | New/Edit |
| --- | --- | --- |
| `MakeDnaSeqMergeExperimentsNextflowConfig.pm` | remove 6 obsolete params, add ploidy read+validate | edit |
| `dnaSeqMergeExperiments.xml` | drop obsolete params, cacheFile→absolute, thread experimentConfigGlob | edit |
| `dnaseq.xml` | uncomment/rewire merge subgraph; add touch, copy-back, ext-db, plugin steps | edit |
| `InsertVariationFeatures.pm` (WorkflowStep) | thin plugin wrapper | new |
| `CopyDnaSeqMergeResultsToWebServices.pm` (WorkflowStep) | publish merged VCF+index and hsss dirs to `dnaseq/` webservices | new |

Reused as-is: `TouchFile`, `CopyDataDirFile`, `CreateExtDbAndDbRls`,
`GatherDnaSeqMergeExperimentsInputs`, `RunNextflowWithEntry`, the `InsertVariationFeatures`
plugin. `CopyDnaSeqMergeResultsToWebServices` mirrors `CopyDnaseqBigwigToWebSvc`.

## Known technical debt (accepted, not blocking)

- **Ploidy coupling.** Reading ploidy from generated per-experiment config files couples the
  merge step to a sibling step's output format. Correct long-term home is `apidb.organism`.
  Flagged with an in-code comment.

## Out of scope / open observations

- `mergeCoverageBeds` (`modules/mergeExperiments.nf`) strips `_coverage.bed.gz` while the
  gathered filenames end in `.coverage.bed.gz`; a possible naming mismatch on the nextflow
  side. Not touched here — flag to the nextflow repo separately.
- `allele.dat` / `sample.dat` loading.

## Testing

- Test data: `~/dnaseq_test/merge/output` (contains `variationFeature.dat`,
  `transcript_product.dat`, `snpeff.dat`, `allele.dat`, `sample.dat`, `merged.ann.vcf.gz`,
  `hsss_readFreq{20,40,60,80}`).
- Verify the generated merge config against the `mergeExperiments` profile param set.
- Verify ploidy parse/validate: consistent values pass; disagreeing values die.
- Verify the plugin loads against a test DB (undo via `undoPreprocess`).
