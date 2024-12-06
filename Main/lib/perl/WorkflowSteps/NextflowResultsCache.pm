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



        $datasetDirectory = $datasetSpec;
    }

    my $cacheDir = "$cacheDirBase/$datasetDirectory/$nextflowDirectory";


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
        $self->runCmd(0, "cp -r $resultsPath/* $cacheDir/");
    }
    $self->runCmd($test, "mkdir -p $cacheDir");
    $self->runCmd($test, "cp -r $resultsPath/* $cacheDir/");
  }


}

sub getDatasetSpecFromName {
    my ($self,$test,$datasetName) = @_;


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
sub getMd5DigestForAnnotationSpecs {
    my ($self, $test, $organismAbbrev) = @_;


    # NOTE:  this is the postgres version
    my $sql = "SELECT md5(string_agg(name || '|' ||  version, ',' ORDER BY name,version))
FROM apidb.datasource d
WHERE name LIKE '${organismAbbrev}\_%genome_features_RSRC' ESCAPE '\\'
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
