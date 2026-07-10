# DNASeq mergeExperiments Wiring + Variation Loading Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Wire the `mergeExperiments` nextflow entry into `dnaseq.xml`, persist the `transcript_product.dat` cache across runs, load the merge output into the database via the `InsertVariationFeatures` plugin, and publish the merged VCF and high-speed-search files to webservices.

**Architecture:** Reconcile the generated merge nextflow config with the current `dnaseq-nextflow` param contract (drop 6 obsolete params, add DB-free ploidy derived by reading + validating per-experiment configs). Touch an empty persistent cache file before the run and copy the fresh `transcript_product.dat` back after. Create an ExternalDatabaseRelease (reusing `CreateExtDbAndDbRls`) and load `variationFeature.dat` / `transcript_product.dat` / `snpeff.dat` with one new thin plugin-wrapper step.

**Tech Stack:** Perl (ReFlow WorkflowStep classes), ReFlow workflow XML, Nextflow (`VEuPathDB/dnaseq-nextflow`, entry `mergeExperiments`), GUS plugins.

**Spec:** `docs/superpowers/specs/2026-07-10-dnaseq-merge-experiments-loading-design.md`

**Testing note:** This repo has no unit-test harness (no `t/`, no `Test::More`) and does not run steps outside a live workflow + DB. Verification here is therefore: `perl -c` compile checks resolving deps from the deployed `gus_home`, one runnable harness for the pure ploidy logic, `xmllint` well-formedness, and an end-to-end config-generation dry run against real test data. Full plugin-load and nextflow execution are integration steps requiring a DB/cluster and are out of this plan's automated scope.

**Env vars used by verification commands:**
```bash
export ACW=/home/jbrestel/workspaces/dataLoad/project_home/ApiCommonWorkflow
export GUS_HOME=/home/jbrestel/workspaces/dataLoad/gus_home
export SCRATCH=/tmp/claude-1000/-home-jbrestel-workspaces-dataLoad-project-home-ApiCommonWorkflow/072fb87d-aa46-4ea3-bf75-6c8f6dab4e69/scratchpad
```

---

## File Structure

| File | Responsibility | New/Edit |
| --- | --- | --- |
| `Main/lib/perl/WorkflowSteps/MakeDnaSeqMergeExperimentsNextflowConfig.pm` | Generate merge nextflow.config; derive+validate ploidy | Edit |
| `Main/lib/xml/workflow/dnaSeqMergeExperiments.xml` | Merge subgraph: gather inputs, touch undoneStrains, make config, run nextflow | Edit |
| `Main/lib/perl/WorkflowSteps/InsertVariationFeatures.pm` | Thin wrapper running the `InsertVariationFeatures` plugin | New |
| `Main/lib/perl/WorkflowSteps/CopyDnaSeqMergeResultsToWebServices.pm` | Publish merged VCF+index and hsss dirs to `dnaseq/` webservices | New |
| `Main/lib/xml/workflowTemplates/dnaseq.xml` | Top-level: touch cache, create ext-db, run merge, copy cache back, load variations, publish to webservices | Edit |

---

## Task 1: Ploidy parse+validate helper + config param reconcile

**Files:**
- Modify: `Main/lib/perl/WorkflowSteps/MakeDnaSeqMergeExperimentsNextflowConfig.pm`
- Test harness (scratchpad, not committed): `$SCRATCH/test_parse_ploidy.pl`

### Context

Current file reads 6 params the merge entry no longer uses and is missing `ploidy`. The
per-experiment configs are at `$$parentDataDir$$/*/dnaseqNextflow/analysisDir/nextflow.config`
and contain a line written by `MakeDnaSeqNextflowConfig.pm:71` as:
```
  ploidy                   = 1
```

- [ ] **Step 1: Add the pure ploidy helper sub**

Add this sub to `MakeDnaSeqMergeExperimentsNextflowConfig.pm` immediately after the `use`
statements (before `sub run`). It uses only core Perl so it is testable without a DB.

```perl
# --- TECHNICAL DEBT -------------------------------------------------------
# Ploidy is not a first-class organism attribute in the database, and the
# per-experiment ploidy is only visible inside the dataset-template scope of
# dnaseq.xml. As a workaround we read ploidy back out of the per-experiment
# nextflow configs this workflow already generated and require them to agree.
# This couples the merge step to MakeDnaSeqNextflowConfig.pm's output format.
# Correct long-term home: a ploidy column on apidb.organism.
# -------------------------------------------------------------------------
sub parsePloidyFromConfigs {
  my (@configFiles) = @_;
  die "No per-experiment nextflow config files found to read ploidy from\n"
    unless @configFiles;
  my %seen;
  for my $file (@configFiles) {
    open(my $fh, '<', $file) or die "Can't open experiment config '$file': $!";
    my $ploidy;
    while (my $line = <$fh>) {
      if ($line =~ /^\s*ploidy\s*=\s*(\S+)/) { $ploidy = $1; last; }
    }
    close $fh;
    die "No ploidy value found in experiment config '$file'\n" unless defined $ploidy;
    $seen{$ploidy} = 1;
  }
  my @values = sort keys %seen;
  die "Inconsistent ploidy across experiments (found: @values); refusing to merge\n"
    if @values > 1;
  return $values[0];
}
```

- [ ] **Step 2: Write the runnable test harness and confirm it FAILS to find the sub**

Create `$SCRATCH/test_parse_ploidy.pl`:

```perl
use strict; use warnings;
BEGIN { $ENV{GUS_HOME} ||= '/home/jbrestel/workspaces/dataLoad/gus_home'; }
use lib "$ENV{GUS_HOME}/lib/perl";
use File::Temp qw/tempdir/;

require "/home/jbrestel/workspaces/dataLoad/project_home/ApiCommonWorkflow/Main/lib/perl/WorkflowSteps/MakeDnaSeqMergeExperimentsNextflowConfig.pm";
my $fn = \&ApiCommonWorkflow::Main::WorkflowSteps::MakeDnaSeqMergeExperimentsNextflowConfig::parsePloidyFromConfigs;

sub mkcfg { my ($dir, $name, $ploidy) = @_;
  my $d = "$dir/$name"; mkdir $d;
  open(my $f, '>', "$d/nextflow.config") or die $!;
  print $f "params {\n  ploidy                   = $ploidy\n}\n"; close $f;
  return "$d/nextflow.config";
}

# consistent -> returns the value
my $d1 = tempdir(CLEANUP=>1);
my @c1 = (mkcfg($d1,'a',2), mkcfg($d1,'b',2));
my $v = $fn->(@c1);
die "FAIL consistent: got '$v' expected 2" unless $v eq '2';
print "PASS consistent -> $v\n";

# inconsistent -> dies
my $d2 = tempdir(CLEANUP=>1);
my @c2 = (mkcfg($d2,'a',1), mkcfg($d2,'b',2));
eval { $fn->(@c2) };
die "FAIL: inconsistent should have died" unless $@ =~ /Inconsistent ploidy/;
print "PASS inconsistent -> died: $@";

# empty list -> dies
eval { $fn->() };
die "FAIL: empty should have died" unless $@ =~ /No per-experiment/;
print "PASS empty -> died\n";

# config without ploidy -> dies
my $d3 = tempdir(CLEANUP=>1); mkdir "$d3/a";
open(my $f,'>',"$d3/a/nextflow.config"); print $f "params {}\n"; close $f;
eval { $fn->("$d3/a/nextflow.config") };
die "FAIL: missing ploidy should have died" unless $@ =~ /No ploidy value/;
print "PASS missing-ploidy -> died\n";

print "ALL PASS\n";
```

Run (BEFORE adding the sub, to confirm the harness detects absence — if you already added it in Step 1, temporarily comment the sub out, or just proceed and confirm the PASS in Step 3):
```bash
perl "$SCRATCH/test_parse_ploidy.pl"
```
Expected before sub exists: dies with "Undefined subroutine ...parsePloidyFromConfigs".

- [ ] **Step 3: Run the harness and verify ALL PASS**

Run: `perl "$SCRATCH/test_parse_ploidy.pl"`
Expected output ends with: `ALL PASS`

- [ ] **Step 4: Reconcile params in `sub run`**

Replace the body of `sub run` so it (a) drops the obsolete param reads, (b) derives ploidy, and
(c) writes the new config. Full replacement for `sub run`:

```perl
sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $stagingDir      = join("/", $workflowDataDir, $self->getParamValue("stagingDir"));
  my $outputDir       = join("/", $workflowDataDir, $self->getParamValue("outputDir"));
  my $configPath      = join("/", $workflowDataDir, $self->getParamValue("analysisDir"), $self->getParamValue("configFileName"));
  my $gtfFile         = join("/", $workflowDataDir, $self->getParamValue("gtfFile"));
  my $genomeFastaFile = join("/", $workflowDataDir, $self->getParamValue("genomeFastaFile"));
  my $organismAbbrev  = $self->getParamValue("organismAbbrev");
  my $cacheFile       = join("/", $workflowDataDir, $self->getParamValue("cacheFile"));
  my $undoneStrainsFile = join("/", $workflowDataDir, $self->getParamValue("undoneStrainsFile"));
  my $experimentConfigGlob = join("/", $workflowDataDir, $self->getParamValue("experimentConfigGlob"));

  my $gusConfigFile = $ENV{GUS_HOME}."/config/gus.config";
  die "Config file $gusConfigFile does not exist" unless -e $gusConfigFile;

  my @properties = ();
  my $gusConfig = CBIL::Util::PropertySet->new($gusConfigFile, \@properties, 1);

  my $referenceSql = "select REF_STRAIN_ABBREV from apidb.organism where abbrev = '$organismAbbrev'";
  my $db = GUS::ObjRelP::DbiDatabase->new($gusConfig->{props}->{dbiDsn},
                                          $gusConfig->{props}->{databaseLogin},
                                          $gusConfig->{props}->{databasePassword},
                                          0,0,1,
                                          $gusConfig->{props}->{coreSchemaName});
  my $dbh = $db->getQueryHandle();
  my $referenceStmt = $dbh->prepare($referenceSql);
  $referenceStmt->execute();
  my $referenceStrain;
  while (my @row = $referenceStmt->fetchrow_array()) { $referenceStrain = $row[0]; }

  if ($undo) {
    $self->runCmd(0, "rm -rf $configPath");
    return;
  }

  # ploidy is derived from the per-experiment configs (see parsePloidyFromConfigs).
  my @experimentConfigs = glob($experimentConfigGlob);
  my $ploidy = parsePloidyFromConfigs(@experimentConfigs);

  open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";
  print F
"
params {

  outputDir       = \"$outputDir\"
  cacheFile       = \"$cacheFile\"
  undoneStrains   = \"$undoneStrainsFile\"
  reference_strain = \'$referenceStrain\'
  genomeFastaFile = \"$genomeFastaFile\"
  gtfFile         = \"$gtfFile\"
  ploidy          = $ploidy
  relativeConsensusFilePattern = \"$stagingDir/consensus/*_consensus.fa.gz\"
  vcfFiles                     = \"$stagingDir/vcfs/*.vcf.gz\"
  indelsFiles                  = \"$stagingDir/indels/*.tsv\"
  coverageFiles                = \"$stagingDir/coverage/*.coverage.bed.gz\"

}

singularity {
  enabled = true
  autoMounts = true
}
";
  close(F);
}
```

Note the removed reads: `cacheFileDir`, `varscanDirectory`, `varscanFilePath`, `webServicesDir`,
`extDbRlsSpec`, and the `organism_abbrev` output line. `ploidy` is written as a bare number.

- [ ] **Step 5: Compile-check the module**

Run:
```bash
perl -I "$GUS_HOME/lib/perl" -c "$ACW/Main/lib/perl/WorkflowSteps/MakeDnaSeqMergeExperimentsNextflowConfig.pm"
```
Expected: `... syntax OK`

- [ ] **Step 6: Re-run the ploidy harness (regression)**

Run: `perl "$SCRATCH/test_parse_ploidy.pl"`
Expected: `ALL PASS`

- [ ] **Step 7: Commit**

```bash
cd "$ACW"
git add Main/lib/perl/WorkflowSteps/MakeDnaSeqMergeExperimentsNextflowConfig.pm
git commit -m "dnaseq merge: reconcile nextflow config params; derive+validate ploidy from experiment configs"
```

---

## Task 2: Update the merge subgraph XML

**Files:**
- Modify: `Main/lib/xml/workflow/dnaSeqMergeExperiments.xml`

### Context

Drop obsolete params (`varscanDirectory`, `varscanFilePath`, `webServicesDir`, `extDbRlsSpec`,
and the vestigial `outputDir` param that is never referenced), add an `experimentConfigGlob`
constant, touch an empty `undoneStrains` file (a required nextflow input that nothing currently
creates), and update the config step's paramValues to match Task 1.

- [ ] **Step 1: Replace the whole file**

Overwrite `dnaSeqMergeExperiments.xml` with:

```xml
<workflowGraph name="dnaSeqMergeExperiments">
  <param name="parentDataDir"/>
  <param name="organismAbbrev"/>
  <param name="inputDir"/>
  <param name="genomeFastaFile"/>
  <param name="gtfFile"/>
  <param name="cacheFile"/>
  <param name="undoneStrains"/>

  <constant name="dataDir">$$parentDataDir$$/$$organismAbbrev$$_mergeExperiments</constant>
  <constant name="stagingDir">$$dataDir$$/mergeInputs</constant>
  <constant name="experimentConfigGlob">$$parentDataDir$$/*/dnaseqNextflow/analysisDir/nextflow.config</constant>

  <step name="gatherDnaSeqMergeExperimentsInputs" stepClass="ApiCommonWorkflow::Main::WorkflowSteps::GatherDnaSeqMergeExperimentsInputs">
    <paramValue name="inputDirGlob">$$inputDir$$</paramValue>
    <paramValue name="stagingDir">$$stagingDir$$</paramValue>
  </step>

  <step name="touchUndoneStrains" stepClass="ApiCommonWorkflow::Main::WorkflowSteps::TouchFile">
    <paramValue name="fileName">$$dataDir$$/$$undoneStrains$$</paramValue>
  </step>

  <step name="makeDnaSeqMergeExperimentsNextflowConfig" stepClass="ApiCommonWorkflow::Main::WorkflowSteps::MakeDnaSeqMergeExperimentsNextflowConfig">
    <paramValue name="analysisDir">$$dataDir$$</paramValue>
    <paramValue name="organismAbbrev">$$organismAbbrev$$</paramValue>
    <paramValue name="stagingDir">$$stagingDir$$</paramValue>
    <paramValue name="genomeFastaFile">$$genomeFastaFile$$</paramValue>
    <paramValue name="gtfFile">$$gtfFile$$</paramValue>
    <paramValue name="outputDir">$$dataDir$$/output</paramValue>
    <paramValue name="cacheFile">$$cacheFile$$</paramValue>
    <paramValue name="undoneStrainsFile">$$dataDir$$/$$undoneStrains$$</paramValue>
    <paramValue name="configFileName">nextflow.config</paramValue>
    <paramValue name="experimentConfigGlob">$$experimentConfigGlob$$</paramValue>
    <depends name="gatherDnaSeqMergeExperimentsInputs"/>
    <depends name="touchUndoneStrains"/>
  </step>

  <step name="runDnaSeqMergeExperiments" stepClass="ApiCommonWorkflow::Main::WorkflowSteps::RunNextflowWithEntry">
    <paramValue name="analysisDir">$$dataDir$$</paramValue>
    <paramValue name="resultsDir">$$dataDir$$/output</paramValue>
    <paramValue name="nextflowConfigFile">nextflow.config</paramValue>
    <paramValue name="nextflowWorkflow">VEuPathDB/dnaseq-nextflow</paramValue>
    <paramValue name="isGitRepo">true</paramValue>
    <paramValue name="entry">mergeExperiments</paramValue>
    <paramValue name="gitBranch">main</paramValue>
    <depends name="makeDnaSeqMergeExperimentsNextflowConfig"/>
  </step>

</workflowGraph>
```

- [ ] **Step 2: Verify well-formedness**

Run: `xmllint --noout "$ACW/Main/lib/xml/workflow/dnaSeqMergeExperiments.xml" && echo "XML OK"`
Expected: `XML OK`

- [ ] **Step 3: Confirm cacheFile no longer treated as bare filename**

Run: `grep -n "cacheFileDir\|varscan\|webServices\|extDbRls" "$ACW/Main/lib/xml/workflow/dnaSeqMergeExperiments.xml"`
Expected: no output (all obsolete params gone).

- [ ] **Step 4: Commit**

```bash
cd "$ACW"
git add Main/lib/xml/workflow/dnaSeqMergeExperiments.xml
git commit -m "dnaseq merge subgraph: drop obsolete params, touch undoneStrains, thread experimentConfigGlob and absolute cacheFile"
```

---

## Task 3: New InsertVariationFeatures WorkflowStep class

**Files:**
- Create: `Main/lib/perl/WorkflowSteps/InsertVariationFeatures.pm`

### Context

Thin wrapper mirroring `InsertStudyResults.pm`. The plugin
(`ApiCommonData::Load::Plugin::InsertVariationFeatures`) declares args `inputDir`,
`extDbRlsSpec`, `organismAbbrev`, optional `targetSchema` (defaults to `apidb`, omitted here).

- [ ] **Step 1: Create the file**

```perl
package ApiCommonWorkflow::Main::WorkflowSteps::InsertVariationFeatures;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $inputDir       = $self->getParamValue('inputDir');
  my $extDbRlsSpec   = $self->getParamValue('extDbRlsSpec');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--inputDir $workflowDataDir/$inputDir "
           . "--extDbRlsSpec '$extDbRlsSpec' "
           . "--organismAbbrev '$organismAbbrev'";

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertVariationFeatures", $args);
}

1;
```

- [ ] **Step 2: Compile-check**

Run:
```bash
perl -I "$GUS_HOME/lib/perl" -c "$ACW/Main/lib/perl/WorkflowSteps/InsertVariationFeatures.pm"
```
Expected: `... syntax OK`

- [ ] **Step 3: Confirm the plugin argument names match the wrapper**

Run:
```bash
grep -nE "name => '(inputDir|extDbRlsSpec|organismAbbrev)'" \
  /home/jbrestel/workspaces/dataLoad/project_home/ApiCommonData/Load/plugin/perl/InsertVariationFeatures.pm
```
Expected: three matching lines (one per arg).

- [ ] **Step 4: Commit**

```bash
cd "$ACW"
git add Main/lib/perl/WorkflowSteps/InsertVariationFeatures.pm
git commit -m "Add InsertVariationFeatures WorkflowStep wrapping the variation-loading plugin"
```

---

## Task 4: New CopyDnaSeqMergeResultsToWebServices WorkflowStep class

**Files:**
- Create: `Main/lib/perl/WorkflowSteps/CopyDnaSeqMergeResultsToWebServices.pm`

### Context

Mirrors `CopyDnaseqBigwigToWebSvc.pm` (same `<org>/dnaseq/` webservices base). Publishes the
merged annotated VCF (+index) to `dnaseq/vcf/` and the `hsss_readFreqN` dirs to `dnaseq/readFreqN`
(stripping the `hsss_` prefix). Undo removes only what this step created, never the shared
`dnaseq/` dir.

- [ ] **Step 1: Create the file**

```perl
package ApiCommonWorkflow::Main::WorkflowSteps::CopyDnaSeqMergeResultsToWebServices;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonWorkflow::Main::Util::OrganismInfo;

sub run {
  my ($self, $test, $undo) = @_;

  my $copyFromDir    = $self->getParamValue('copyFromDir');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $relativeDir    = $self->getParamValue('relativeDir');
  my $gusConfigFile  = $self->getParamValue('gusConfigFile');

  my $workflowDataDir = $self->getWorkflowDataDir();
  $gusConfigFile = "$workflowDataDir/$gusConfigFile";
  my $websiteFilesDir = $self->getWebsiteFilesDir($test);

  my $organismNameForFiles =
      $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getNameForFiles();

  my $baseDir   = "$websiteFilesDir/$relativeDir/$organismNameForFiles/dnaseq";
  my $vcfDir    = "$baseDir/vcf";
  my $sourceDir = "$workflowDataDir/$copyFromDir";

  if ($undo) {
    $self->runCmd(0, "rm -rf $vcfDir $baseDir/readFreq20 $baseDir/readFreq40 $baseDir/readFreq60 $baseDir/readFreq80");
    return;
  }

  $self->testInputFile('copyFromDir', $sourceDir);

  # merged annotated VCF + index
  $self->runCmd($test, "mkdir -p $vcfDir");
  $self->runCmd($test, "cp $sourceDir/merged.ann.vcf.gz $vcfDir/");
  $self->runCmd($test, "cp $sourceDir/merged.ann.vcf.gz.tbi $vcfDir/");

  # high-speed-search dirs: hsss_readFreqN -> readFreqN
  my @hsssDirs = glob("$sourceDir/hsss_readFreq*");
  die "No hsss_readFreq* directories found in '$sourceDir'" unless @hsssDirs || $test;
  foreach my $dir (@hsssDirs) {
    my $name = (split '/', $dir)[-1];   # hsss_readFreq20
    (my $target = $name) =~ s/^hsss_//; # readFreq20
    $self->runCmd($test, "rm -rf $baseDir/$target");
    $self->runCmd($test, "cp -r $dir $baseDir/$target");
  }
}

1;
```

- [ ] **Step 2: Compile-check**

Run:
```bash
perl -I "$GUS_HOME/lib/perl" -c "$ACW/Main/lib/perl/WorkflowSteps/CopyDnaSeqMergeResultsToWebServices.pm"
```
Expected: `... syntax OK`

- [ ] **Step 3: Verify the prefix-strip logic in isolation**

Run:
```bash
perl -e '
  for my $name (qw/hsss_readFreq20 hsss_readFreq40 hsss_readFreq60 hsss_readFreq80/) {
    (my $t = $name) =~ s/^hsss_//;
    print "$name -> $t\n";
  }
'
```
Expected:
```
hsss_readFreq20 -> readFreq20
hsss_readFreq40 -> readFreq40
hsss_readFreq60 -> readFreq60
hsss_readFreq80 -> readFreq80
```

- [ ] **Step 4: Commit**

```bash
cd "$ACW"
git add Main/lib/perl/WorkflowSteps/CopyDnaSeqMergeResultsToWebServices.pm
git commit -m "Add CopyDnaSeqMergeResultsToWebServices: publish merged VCF and hsss dirs to dnaseq webservices"
```

---

## Task 5: Rewire dnaseq.xml (touch cache, ext-db, merge, copy-back, load, publish)

**Files:**
- Modify: `Main/lib/xml/workflowTemplates/dnaseq.xml`

### Context

Add constants for the merge dirs, persistent cache, and ext-db spec; add the touch/ext-db steps;
uncomment and re-parameterize the merge subgraph (per Task 2's param set); add the copy-back and
plugin steps.

- [ ] **Step 1: Add constants after the existing `<constant>` block (after line 16, `chrsForCalcsFile`)**

Insert:

```xml
  <constant name="mergeExperimentsDir">$$dataDir$$/$$organismAbbrev$$_mergeExperiments</constant>
  <constant name="mergeOutputDir">$$mergeExperimentsDir$$/output</constant>
  <constant name="transcriptProductCache">$$dataDir$$/$$organismAbbrev$$_transcript_product.cache.dat</constant>
  <constant name="dnaSeqVariationExtDbRlsSpec">$$organismAbbrev$$_dnaSeqVariations|do_not_care</constant>
```

- [ ] **Step 2: Add the touch and ext-db steps immediately before `makeMergeExperimentsDataDir`**

Insert (just before the existing `<step name="makeMergeExperimentsDataDir" ...>`):

```xml
  <step name="touchTranscriptProductCache" stepClass="ApiCommonWorkflow::Main::WorkflowSteps::TouchFile">
    <paramValue name="fileName">$$transcriptProductCache$$</paramValue>
    <depends name="makeDataDir"/>
  </step>

  <step name="createDnaSeqVariationExtDbRls" stepClass="ApiCommonWorkflow::Main::WorkflowSteps::CreateExtDbAndDbRls" stepLoadTypes="plugin">
    <paramValue name="extDbRlsSpec">$$dnaSeqVariationExtDbRlsSpec$$</paramValue>
    <paramValue name="gusConfigFile">$$gusConfigFile$$</paramValue>
    <depends name="makeDataDir"/>
  </step>
```

- [ ] **Step 3: Replace the commented-out TODO block (lines 98-115) with the live steps**

Delete the `<!-- TODO ... -->` block and replace with:

```xml
  <subgraph name="runDnaSeqMergeExperiments" xmlFile="dnaSeqMergeExperiments.xml">
    <paramValue name="parentDataDir">$$dataDir$$</paramValue>
    <paramValue name="organismAbbrev">$$organismAbbrev$$</paramValue>
    <paramValue name="inputDir">$$dataDir$$/*/dnaseqNextflow/analysisDir/results</paramValue>
    <paramValue name="genomeFastaFile">$$genomeFastaFile$$</paramValue>
    <paramValue name="gtfFile">$$gtfFile$$</paramValue>
    <paramValue name="cacheFile">$$transcriptProductCache$$</paramValue>
    <paramValue name="undoneStrains">undoneStrains.txt</paramValue>
    <depends name="makeMergeExperimentsDataDir"/>
    <depends name="touchTranscriptProductCache"/>
  </subgraph>

  <step name="copyTranscriptProductCache" stepClass="ApiCommonWorkflow::Main::WorkflowSteps::CopyDataDirFile">
    <paramValue name="fromFile">$$mergeOutputDir$$/transcript_product.dat</paramValue>
    <paramValue name="toFile">$$transcriptProductCache$$</paramValue>
    <depends name="runDnaSeqMergeExperiments"/>
  </step>

  <step name="insertVariationFeatures" stepClass="ApiCommonWorkflow::Main::WorkflowSteps::InsertVariationFeatures" stepLoadTypes="plugin">
    <paramValue name="inputDir">$$mergeOutputDir$$</paramValue>
    <paramValue name="extDbRlsSpec">$$dnaSeqVariationExtDbRlsSpec$$</paramValue>
    <paramValue name="organismAbbrev">$$organismAbbrev$$</paramValue>
    <depends name="runDnaSeqMergeExperiments"/>
    <depends name="createDnaSeqVariationExtDbRls"/>
  </step>

  <step name="copyMergeResultsToWebServices" stepClass="ApiCommonWorkflow::Main::WorkflowSteps::CopyDnaSeqMergeResultsToWebServices">
    <paramValue name="copyFromDir">$$mergeOutputDir$$</paramValue>
    <paramValue name="organismAbbrev">$$organismAbbrev$$</paramValue>
    <paramValue name="relativeDir">$$relativeWebServicesDir$$</paramValue>
    <paramValue name="gusConfigFile">$$gusConfigFile$$</paramValue>
    <depends name="runDnaSeqMergeExperiments"/>
  </step>
```

- [ ] **Step 4: Verify well-formedness**

Run: `xmllint --noout "$ACW/Main/lib/xml/workflowTemplates/dnaseq.xml" && echo "XML OK"`
Expected: `XML OK`

- [ ] **Step 5: Sanity-check the dependency wiring**

Run:
```bash
grep -nE "<step name=|<subgraph name=|depends name=|<constant name=\"(mergeOutputDir|transcriptProductCache|dnaSeqVariationExtDbRlsSpec)\"" \
  "$ACW/Main/lib/xml/workflowTemplates/dnaseq.xml"
```
Expected: the new step/subgraph names appear (`touchTranscriptProductCache`,
`createDnaSeqVariationExtDbRls`, `runDnaSeqMergeExperiments`, `copyTranscriptProductCache`,
`insertVariationFeatures`, `copyMergeResultsToWebServices`); `insertVariationFeatures`,
`copyTranscriptProductCache`, and `copyMergeResultsToWebServices` each depend on
`runDnaSeqMergeExperiments`; `insertVariationFeatures` also depends on
`createDnaSeqVariationExtDbRls`; and no `<!-- TODO` remains.

- [ ] **Step 6: Commit**

```bash
cd "$ACW"
git add Main/lib/xml/workflowTemplates/dnaseq.xml
git commit -m "dnaseq.xml: wire mergeExperiments subgraph, cache touch/copy-back, ext-db and variation load"
```

---

## Task 6: End-to-end config-generation verification against test data

**Files:** none (verification only)

### Context

Exercise the real config generator's ploidy path against fabricated per-experiment configs and
the real merge output layout, without a DB. We bypass the DB (reference_strain) by calling the
pure helper against fixtures and by inspecting the emitted config template shape.

- [ ] **Step 1: Fabricate per-experiment configs mirroring the real layout and run the helper**

```bash
cd "$SCRATCH"
rm -rf mergecheck && mkdir -p mergecheck/expA/dnaseqNextflow/analysisDir mergecheck/expB/dnaseqNextflow/analysisDir
printf 'params {\n  ploidy                   = 2\n}\n' > mergecheck/expA/dnaseqNextflow/analysisDir/nextflow.config
printf 'params {\n  ploidy                   = 2\n}\n' > mergecheck/expB/dnaseqNextflow/analysisDir/nextflow.config
perl -e '
  BEGIN { $ENV{GUS_HOME} ||= "/home/jbrestel/workspaces/dataLoad/gus_home"; }
  use lib "$ENV{GUS_HOME}/lib/perl";
  require "/home/jbrestel/workspaces/dataLoad/project_home/ApiCommonWorkflow/Main/lib/perl/WorkflowSteps/MakeDnaSeqMergeExperimentsNextflowConfig.pm";
  my @g = glob("'"$SCRATCH"'/mergecheck/*/dnaseqNextflow/analysisDir/nextflow.config");
  my $p = ApiCommonWorkflow::Main::WorkflowSteps::MakeDnaSeqMergeExperimentsNextflowConfig::parsePloidyFromConfigs(@g);
  print "derived ploidy = $p\n";
'
```
Expected: `derived ploidy = 2`

- [ ] **Step 2: Confirm the mismatch case aborts**

```bash
printf 'params {\n  ploidy                   = 1\n}\n' > "$SCRATCH/mergecheck/expB/dnaseqNextflow/analysisDir/nextflow.config"
perl -e '
  BEGIN { $ENV{GUS_HOME} ||= "/home/jbrestel/workspaces/dataLoad/gus_home"; }
  use lib "$ENV{GUS_HOME}/lib/perl";
  require "/home/jbrestel/workspaces/dataLoad/project_home/ApiCommonWorkflow/Main/lib/perl/WorkflowSteps/MakeDnaSeqMergeExperimentsNextflowConfig.pm";
  my @g = glob("'"$SCRATCH"'/mergecheck/*/dnaseqNextflow/analysisDir/nextflow.config");
  eval { ApiCommonWorkflow::Main::WorkflowSteps::MakeDnaSeqMergeExperimentsNextflowConfig::parsePloidyFromConfigs(@g) };
  print $@ =~ /Inconsistent ploidy/ ? "OK aborted on mismatch\n" : "UNEXPECTED: $@";
'
```
Expected: `OK aborted on mismatch`

- [ ] **Step 3: Confirm the merge output artifacts each consumer needs exist in the test data**

```bash
# plugin inputs
ls ~/dnaseq_test/merge/output/{variationFeature.dat,transcript_product.dat,snpeff.dat}
# cache copy-back source
ls ~/dnaseq_test/merge/output/transcript_product.dat
# webservices copy sources
ls ~/dnaseq_test/merge/output/{merged.ann.vcf.gz,merged.ann.vcf.gz.tbi}
ls -d ~/dnaseq_test/merge/output/hsss_readFreq20 ~/dnaseq_test/merge/output/hsss_readFreq40 \
      ~/dnaseq_test/merge/output/hsss_readFreq60 ~/dnaseq_test/merge/output/hsss_readFreq80
```
Expected: every path listed. These are the required inputs for the plugin, cache copy-back, and
the webservices publish step respectively.

- [ ] **Step 4: Final XML validation sweep**

```bash
xmllint --noout "$ACW/Main/lib/xml/workflow/dnaSeqMergeExperiments.xml" \
  && xmllint --noout "$ACW/Main/lib/xml/workflowTemplates/dnaseq.xml" \
  && echo "ALL XML OK"
```
Expected: `ALL XML OK`

- [ ] **Step 5: No commit (verification only)**

If any check failed, return to the owning task and fix before proceeding to integration.

---

## Post-plan integration (manual, requires DB + cluster — out of automated scope)

1. Build/deploy source to `gus_home` (the project's normal `bld`/install step).
2. Run the `dnaseq` workflow against a test organism with ≥2 dnaseq experiments; confirm the
   merge subgraph produces `<mergeOutputDir>/transcript_product.dat`, the cache file is
   populated afterward, `InsertVariationFeatures` loads rows for `${organismAbbrev}_dnaSeqVariations`,
   and the webservices `<org>/dnaseq/` dir gains `vcf/merged.ann.vcf.gz(.tbi)` and
   `readFreq{20,40,60,80}/` (prefix stripped).
3. Second run: confirm the persistent cache (non-empty) is passed as `--cache_file` and reused.
4. Report to the `dnaseq-nextflow` repo the `mergeCoverageBeds` `_coverage.bed.gz` vs
   `.coverage.bed.gz` naming observation (see spec).
