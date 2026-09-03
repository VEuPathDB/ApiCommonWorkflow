package ApiCommonWorkflow::Main::WorkflowSteps::UpdateOrthoIncrementalPersistentCache;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

# Incremental counterpart to UpdateOrthoPeripheralPersistentCache.pm.
#
# That step (full-rebuild path only) starts with "rm -rf officialDiamondCache/*"
# and fully replaces everything -- correct there, since a full rebuild
# recomputes every group and every organism. This step must NOT do that: an
# incremental run only recomputes a subset (the touched groups / the
# organisms that actually changed), so several cached artifacts here are
# merged/overlaid onto the existing cache rather than replacing it outright.
# Without this distinction, this step would silently delete the persistent
# record of every group/organism this run didn't touch.
#
# Also matters for THIS run, not just the next one: CopyPeripheralGroupsResultsFromCache.pm
# runs after either path completes and unconditionally overwrites
# postProcessingEntryResults/postResidualEntryResults/peripheralEntryResults
# in $analysisDir with whatever is currently cached, right before
# loadCoreGroups/loadResidualGroups read those same paths. For a full
# rebuild that's harmless (updateOrthoPeripheralPersistentCache just
# refreshed the cache with this exact run's data first). For incremental,
# without this step the cache stays stale and that overwrite would replace
# this run's own freshly-computed group files with the pre-run cache
# content immediately before the loaders read them.
#
# Unlike the peripheral version, this reads directly from $analysisDir
# rather than the "genesAndProteins" staged-and-later-deleted mirror: by the
# time this step runs (last in orthoFinderIncremental.xml, after the
# existing copyIncremental*ForLoaders/concatenateIncremental* fixup steps),
# $analysisDir/{peripheralEntryResults,postResidualEntryResults,
# postProcessingEntryResults}/ already hold this run's correct, final,
# loader-facing content -- reusing those same paths (passed in as
# paramValues, same convention orthoFinderIncremental.xml's existing fixup
# steps already use) avoids re-deriving anything and guarantees the cache
# matches exactly what this run's loaders actually used.

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $checkSumFile = join("/", $workflowDataDir, $self->getParamValue("checkSum"));
  my $newGroupsFile = join("/", $workflowDataDir, $self->getParamValue("newGroupsFile"));
  my $previousGroups = join("/", $workflowDataDir, $self->getParamValue("previousGroups"));
  my $fullProteomeFile = join("/", $workflowDataDir, $self->getParamValue("fullProteomeFile"));
  my $groupsFile = join("/", $workflowDataDir, $self->getParamValue("groupsFile"));
  my $coreStatsFile = join("/", $workflowDataDir, $self->getParamValue("coreStatsFile"));
  my $peripheralStatsFile = join("/", $workflowDataDir, $self->getParamValue("peripheralStatsFile"));
  my $intraGroupBlastFile = join("/", $workflowDataDir, $self->getParamValue("intraGroupBlastFile"));
  my $residualStatsFile = join("/", $workflowDataDir, $self->getParamValue("residualStatsFile"));
  my $intraResidualGroupBlastFile = join("/", $workflowDataDir, $self->getParamValue("intraResidualGroupBlastFile"));
  my $reformattedGroupsFile = join("/", $workflowDataDir, $self->getParamValue("reformattedGroupsFile"));
  my $mergedCoreBestReps = join("/", $workflowDataDir, $self->getParamValue("mergedCoreBestReps"));
  my $mergedResidualBestReps = join("/", $workflowDataDir, $self->getParamValue("mergedResidualBestReps"));
  my $narrowResidualBestReps = join("/", $workflowDataDir, $self->getParamValue("narrowResidualBestReps"));
  my $buildVersionFile = join("/", $workflowDataDir, $self->getParamValue("buildVersionFile"));
  my $bestRepsFullFasta = join("/", $workflowDataDir, $self->getParamValue("bestRepsFullFasta"));
  my $similarGroupsFile = join("/", $workflowDataDir, $self->getParamValue("similarGroupsFile"));
  my $postProcessingEntryResultsDir = join("/", $workflowDataDir, $self->getParamValue("postProcessingEntryResultsDir"));
  my $proteinToOrganismFile = join("/", $workflowDataDir, $self->getParamValue("proteinToOrganismFile"));
  my $touchedGroupFastasDir = join("/", $workflowDataDir, $self->getParamValue("touchedGroupFastasDir"));
  my $residualGroupFastasDir = join("/", $workflowDataDir, $self->getParamValue("residualGroupFastasDir"));

  my $preprocessedDataCache = $self->getSharedConfig('preprocessedDataCache');
  my $orthoBuildVersion = $self->getSharedConfig('buildVersion');
  my $cacheDir = "${preprocessedDataCache}/OrthoMCL/OrthoMCL_peripheralGroups/officialDiamondCache";

  if ($undo) {
      $self->runCmd(0, "echo 'undo'");
  }
  elsif ($test) {
      $self->runCmd(0, "echo 'test'");
  }
  else {

      $self->runCmd(0, "cp $newGroupsFile $cacheDir/newGroups.txt");
      $self->runCmd(0, "cp -r $checkSumFile $cacheDir/checkSum.tsv");

      # --- Full replace: these are comprehensive in the incremental output
      #     too (either recomputed against the whole current group state by
      #     the reused postResidualEntry/postProcessingEntry subgraphs, or
      #     already fixed up in place by orthoFinderIncremental.xml's own
      #     copyIncremental*ForLoaders/concatenateIncremental* steps that run
      #     before this one). ---

      $self->runCmd(0, "cp -r $newGroupsFile $cacheDir/fullGroupFile.txt");
      $self->runCmd(0, "cp -r $previousGroups $cacheDir/previousGroups.txt");
      $self->runCmd(0, "cp -r $groupsFile $cacheDir/GroupsFile.txt");
      $self->runCmd(0, "cp -r $bestRepsFullFasta $cacheDir/");
      $self->runCmd(0, "cp -r $similarGroupsFile $cacheDir/");
      $self->runCmd(0, "cp -r $postProcessingEntryResultsDir/ortho${orthoBuildVersion}db.dmnd $cacheDir/");

      # fullProteome.fasta itself, not just the .dmnd built from it -- the
      # next incremental run's previousFullProteome.fasta is copied straight
      # from here (copyPeripheralFullProteomeForIncremental). Without this,
      # every incremental run after the first would keep combining against a
      # previousFullProteome frozen at the last full rebuild, silently
      # missing every organism update made by intervening incremental runs.
      $self->runCmd(0, "cp -r $fullProteomeFile $cacheDir/fullProteome.fasta");

      $self->runCmd(0, "cp -r $reformattedGroupsFile $cacheDir/");
      $self->runCmd(0, "cp -r $buildVersionFile $cacheDir/residualBuildVersion.txt");

      $self->runCmd(0, "mkdir -p $cacheDir/groupStats");
      $self->runCmd(0, "cp -r $coreStatsFile $cacheDir/groupStats/");
      $self->runCmd(0, "cp -r $peripheralStatsFile $cacheDir/groupStats/");
      $self->runCmd(0, "cp -r $residualStatsFile $cacheDir/groupStats/");
      $self->runCmd(0, "cp -r $intraGroupBlastFile $cacheDir/");
      $self->runCmd(0, "cp -r $intraResidualGroupBlastFile $cacheDir/");

      # coreBestReps.txt is a groupId->seqId mapping, not a fasta --
      # coreBestReps.fasta (this run's other core-best-rep output) is a
      # different shape and can't stand in for it. mergedCoreBestReps.txt is
      # the actual comprehensive mapping-format equivalent (see
      # orthoFinder-nextflow's mergeBestReps), and unlike the residual side
      # it's complete on its own -- no new core/peripheral groups get
      # created by the incremental path, only residual ones do.
      $self->runCmd(0, "cp -r $mergedCoreBestReps $cacheDir/coreBestReps.txt");

      # residualBestReps.txt: unlike the loader-facing residual stats/blast
      # files, nothing in orthoFinderIncremental.xml already combines this
      # one, so do it here -- same touched-pre-existing (mergedResidualBestReps.txt)
      # + brand-new-this-run ($narrowResidualBestReps) split as those had.
      $self->runCmd(0, "cat $mergedResidualBestReps $narrowResidualBestReps > $cacheDir/residualBestReps.txt");

      # --- Merge, not replace: these are per-group/per-organism artifacts
      #     that the incremental run only regenerates for what actually
      #     changed. Overwriting the cache with just this run's subset would
      #     silently lose every untouched group/organism. ---

      $self->runCmd(0, "mergeProteinToOrganismCache --oldCache $cacheDir/proteinToOrganism.tsv --newMapping $proteinToOrganismFile --output $cacheDir/proteinToOrganism.tsv.new");
      $self->runCmd(0, "mv $cacheDir/proteinToOrganism.tsv.new $cacheDir/proteinToOrganism.tsv");

      $self->runCmd(0, "mkdir -p $cacheDir/groupFastas");
      $self->runCmd(0, "cp -r $touchedGroupFastasDir/*.fasta $cacheDir/groupFastas/");

      $self->runCmd(0, "mkdir -p $cacheDir/residualGroupFastas");
      $self->runCmd(0, "cp -r $residualGroupFastasDir/*.fasta $cacheDir/residualGroupFastas/");

      # --- Deferred: not read by any loader, so not correctness-critical for
      #     this run, but left stale in the cache. ---
      #
      # peripherals.fasta: no incremental-path equivalent computed this run.
      #
      # peripheralCacheDir(.tar.gz): a per-organism diamond-results cache that
      # only accelerates a FUTURE full rebuild (skip re-diamonding an
      # unchanged peripheral organism against core). The incremental path
      # computes similarity completely differently (one combined
      # stable-groups DB, not per-organism-pair), so it has no equivalent
      # results to contribute here. Left untouched -- meaning a future full
      # rebuild could reuse stale diamond results for organisms that changed
      # via incremental runs since. Not fixed here; needs its own
      # invalidation mechanism (e.g. drop cache entries for organisms in
      # outdated.txt) as a follow-up.

  }
}

1;
