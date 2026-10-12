package ApiCommonWorkflow::Main::WorkflowSteps::NextflowResultsCache;
@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use File::Basename;


sub run {
    my ($self, $test, $undo) = @_;

    my $mode = $self->getParamValue('mode');
    my $organismAbbrev = $self->getParamValue('organismAbbrev');

    my $preprocessedDataCache = $self->getSharedConfig('preprocessedDataCache');

    my $foundNextflowResults = $self->getParamValue("foundNextflowResults");
    my $resultsDir = $self->getParamValue("resultsDir");

    my ($genomeName, $genomeVersion) = split(/\|/, $self->getParamValue("genomeSpec"));

    my $projectName = $self->getParamValue("projectName");
    my $nextflowWorkflow = $self->getParamValue("nextflowWorkflow");

    my $databaseVersion = &getDatabaseVersion($nextflowWorkflow);

    my $nextflowBranch = $self->getSharedConfig("${nextflowWorkflow}.branch");
    $nextflowWorkflow =~ s/\//_/g;
 
    my $nextflowDirectory;
    if ($databaseVersion) {
        $nextflowDirectory = "${nextflowWorkflow}_${nextflowBranch}/${databaseVersion}";
    }  
    else {
        $nextflowDirectory = "${nextflowWorkflow}_${nextflowBranch}";
    }

    my $cacheDirBase = "$preprocessedDataCache/$projectName/${genomeName}_${genomeVersion}";

    my $datasetSpec = $self->getParamValue("datasetSpec");

    my $isProteomeAnalysis = $self->getBooleanParamValue("isProteomeAnalysis");

    my $datasetDirectory = $isProteomeAnalysis ? "genesAndProteins" : "genome";
    if($datasetSpec) {
        if($datasetSpec =~ /\|/) {
            $datasetSpec =~ s/\|/_/g;
        }
        else {
            $datasetSpec = $self->getDatasetSpecFromName($test, $datasetSpec);
        }



        $datasetDirectory = "${datasetDirectory}/${datasetSpec}";
    }

    my $cacheDir = "${cacheDirBase}/${datasetDirectory}/${nextflowDirectory}";


    if($isProteomeAnalysis) {
        my $annotationDigest = $self->getMd5DigestForAnnotationSpecs($test, $organismAbbrev);

        # NOTE: put the human readable directories first
        $cacheDir = "$cacheDir/$annotationDigest";
    }

    my $resultsPath = $self->getWorkflowDataDir() . "/" . $resultsDir;
    my $foundNextflowResultsFile = $self->getWorkflowDataDir() . "/" . $foundNextflowResults;

    if($mode eq "copyTo") {
        $self->copyTo($test, $undo, $cacheDir, $resultsPath);
    }
    else {
        $self->checkAndCopyFrom($test, $undo, $cacheDir, $resultsPath, $foundNextflowResultsFile);
    }
}


sub checkAndCopyFrom {

  my ($self, $test, $undo, $cacheDir, $resultsPath, $foundNextflowResultsFile) = @_;

  my $hasCacheFile = $self->hasCacheFile($cacheDir);
  if($undo) {
    $self->runCmd($test, "rm -f $foundNextflowResultsFile");
    $self->runCmd($test, "rm -rf $resultsPath/*");
  }
  else {
    if($hasCacheFile) {
      $self->runCmd($test, "mkdir $resultsPath") unless(-e $resultsPath);
      $self->runCmd($test, "touch $foundNextflowResultsFile");
      $self->runCmd($test, "cp -r $cacheDir/* $resultsPath");
    }     
  }
}


sub hasCacheFile {
    my ($self, $cacheDir) = @_;

    if(-d $cacheDir) {
	opendir(my $dh, $cacheDir) or die "Can't open $cacheDir for reading: $!";
	while (readdir($dh)) {
	    next if ($_ eq '.' or $_ eq '..');

	    closedir($dh);
	    return 1;
	}
	closedir($dh);
    }

    return 0;
}



sub copyTo {
  my ($self, $test, $undo, $cacheDir, $resultsPath) = @_;

  if($undo) {} #nothing to see here
  else {
        if ($test) {
        $cacheDir =~ s/\s+//g;      # Remove all whitespace
        $cacheDir =~ s/\R\z//;      # Remove any newline or carriage return at the end
            $self->runCmd(0, "mkdir -p $cacheDir");
        $self->copyResultsIntoCache(0, $cacheDir, $resultsPath);
    }
    $self->runCmd($test, "mkdir -p $cacheDir");

    $self->copyResultsIntoCache($test, $cacheDir, $resultsPath);
  }
}

# $cacheDir is shared/accumulated across every nextflow entry that feeds this cache
# (peripheralEntry, residualEntry, postResidualEntry, postProcessingEntry all copy into
# the same cache key), and is never reset between unrelated runs -- only the caller's
# higher-level "officialDiamondCache" wipe (UpdateOrthoPeripheralPersistentCache.pm) is,
# and only after already copying from here. A bare "cp -r $resultsPath/* $cacheDir/"
# overwrites a same-named FILE cleanly, but MERGES into a same-named DIRECTORY instead of
# replacing it -- so a stale file left behind by any earlier, unrelated run (an abandoned
# incremental attempt, say) silently survives inside a later run's "fresh" copy forever.
#
# Recursing and clearing at the FILE level (not wiping a whole top-level directory
# before recopying it) matters: some of these directories -- groupStats being the clear
# case -- are shared landing zones that *different* nextflow entries each contribute a
# different subset of files to (peripheralEntry's own call here writes core_stats.txt/
# peripheral_stats.txt into groupStats/; postResidualEntry's separate call later writes
# only residual_stats.txt into that same cache subdirectory). Wiping the whole directory
# before either call's copy would destroy the other call's already-cached files. Clearing
# only each individual file's own prior cache entry avoids that, while still replacing any
# stale same-named file from an earlier run.
sub copyResultsIntoCache {
  my ($self, $test, $cacheDir, $resultsPath) = @_;

  foreach my $item (glob("$resultsPath/*")) {
    my $basename = File::Basename::basename($item);
    if (-d $item) {
      $self->runCmd($test, "mkdir -p $cacheDir/$basename");
      $self->copyResultsIntoCache($test, "$cacheDir/$basename", $item);
    }
    else {
      $self->runCmd($test, "rm -f $cacheDir/$basename");
      $self->runCmd($test, "cp $item $cacheDir/");
    }
  }
}

sub getDatasetSpecFromName {
    my ($self,$test,$datasetName) = @_;

    $datasetName = getRefDatasetName ($self, $test, $datasetName) if ($datasetName =~ /_dbEST_RSRC$/);

    my $sql = "SELECT name || '_' ||  version as spec
FROM apidb.datasource d
WHERE name = '${datasetName}'";

    my $gusConfigFile = "--gusConfigFile \"" . $self->getGusConfigFile() . "\"";

    my $cmd = "getValueFromTable --idSQL \"$sql\" $gusConfigFile ";

    my $datasetSpec = $self->runCmd($test, $cmd);

    unless($datasetSpec) {
        $self->error("could not determine datasetSpec for dataset name=$datasetName");
    }
    return $datasetSpec

}

sub getRefDatasetName {
    my ($self,$test,$datasetName) = @_;
    my $refDatasetName;
    if ($datasetName =~ /(.+)_dbEST_RSRC$/) {
      my $abbrev = $1;
      my $subSql = "select ref_strain_abbrev from apidb.organism where abbrev like '$abbrev'";
      my $gusConfigFile = "--gusConfigFile \"" . $self->getGusConfigFile() . "\"";
      my $subcmd = "getValueFromTable --idSQL \"$subSql\" $gusConfigFile";
      my $refAbbrev = $self->runCmd($test, $subcmd);
      if ($refAbbrev) {
	$self->log ("found reference genome $refAbbrev for $abbrev");
	return $refAbbrev . "_dbEST_RSRC";
      } else {
	die "can't found reference genome abbrev for $abbrev";
      }
    } else {
      return $datasetName;
    }
}

sub getMd5DigestForAnnotationSpecs {
    my ($self, $test, $organismAbbrev) = @_;

    # NOTE:  this is the postgres version
    my $sql = "SELECT md5(string_agg(name || '|' ||  version, ',' ORDER BY name,version))
FROM apidb.datasource d
WHERE name LIKE '${organismAbbrev}\_%genome_features_RSRC' ESCAPE '\\'
OR name LIKE '${organismAbbrev}\_orthomclProteome_RSRC' ESCAPE '\\'
OR name LIKE '${organismAbbrev}\_orthomclPeripheralProteome_RSRC' ESCAPE '\\'
OR name LIKE '${organismAbbrev}\_%primary_genome_RSRC' ESCAPE '\\'";


    my $gusConfigFile = "--gusConfigFile \"" . $self->getGusConfigFile() . "\"";

    my $cmd = "getValueFromTable --idSQL \"$sql\" $gusConfigFile ";

    my $digest = $self->runCmd($test, $cmd);

    unless($digest) {
        $self->error("could not determine annotation digest for organism $organismAbbrev");
    }
    return $digest
}

sub getDatabaseVersion {
  my ($self, $nextflowWorkflow) = @_;
  my $databaseVersion;
  if ($nextflowWorkflow eq "VEuPathDB/iprscan5-nextflow") {
    $databaseVersion = $self->getSharedConfig('interproscanDatabaseDirectory');
  }
  return $databaseVersion;
}


1;
