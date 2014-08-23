package ApiCommonWorkflow::Main::WorkflowSteps::RunPairwiseMercatorMavid;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    # find all the organisms to process in the mercator inputs dir produced earlier in the workflow.
    # the dir should have a .gff and .fasta for each organism (and only that).

    # for each pair we create a tmp dir to pass to mercator.  it holds the pair's input files.
    # mercator writes its output in that dir

    # however, we first check to see if we have a current output dir in the cache.  if so use it,
    # else, really run mercator, and copy the outputs to the cache

    my $mercatorInputsDir = $self->getParamValue('mercatorInputsDir'); # holds lots of .gff and .fasta files
    my $mercatorOutputsDir = $self->getParamValue('mercatorOutputsDir'); # will hold a dir per pair
    my $mercatorCacheDir = $self->getParamValue('mercatorCacheDir'); # will hold a dir per pair
    my $mercatorTmpDir = $self->getParamValue('mercatorTmpDir'); # will hold temp inputs for mercator

    my $cndSrcBin = $self->getConfig('cndSrcBin');
    my $mavid = $self->getConfig('mavidExe');

    my $workflowDataDir = $self->getWorkflowDataDir();

    if ($undo) {
	$self->runCmd(0, "rm -fr $workflowDataDir/$mercatorOutputsDir");
	return;
    }

    my @organismAbbrevs = $self->findOrganismAbbrevs("$workflowDataDir/$mercatorInputsDir"); # tests .fasta and .gff existence
    my $isDraftHash = $self->getIsDraftHash(\@organismAbbrevs, $test);  # hash of 0/1 for each organism

    # create and clean out needed dirs
    $self->runCmd(0, "rm -r $workflowDataDir/$mercatorOutputsDir") if -e "$workflowDataDir/$mercatorOutputsDir";
    mkdir("$workflowDataDir/$mercatorOutputsDir")
	|| $self->error("Could not make dir '$workflowDataDir/$mercatorOutputsDir'");

    $self->runCmd($test, "rm -r $workflowDataDir/$mercatorTmpDir") if -e "$workflowDataDir/$mercatorTmpDir";
    mkdir("$workflowDataDir/$mercatorTmpDir")
	|| $self->error("Could not make dir '$workflowDataDir/$mercatorTmpDir'");

    my $cacheDir = "$workflowDataDir/$mercatorCacheDir";
    mkdir("$workflowDataDir/$mercatorCacheDir");

    # always re-run unaligned pairs
    my $skippedDir = "$workflowDataDir/pairsWithNoAlignment";
    $self->runCmd($test, "rm -r $skippedDir") if -e "$skippedDir";
    mkdir("$skippedDir")
	|| $self->error("Could not make dir '$skippedDir'");


    foreach my $orgA (@organismAbbrevs) {
        ## next if the sequence's SO TermName of $orgA or $orgB is only mito- or api-
        next unless ($self->ifSkipOnSoTermName($orgA, $test) eq 'no');

	foreach my $orgB (@organismAbbrevs) {
	    next unless ($self->ifSkipOnSoTermName($orgB, $test) eq 'no');

	    next unless $orgA gt $orgB;  # only do each pair once, and don't do self-self

	    my $pairOutputDir = "$workflowDataDir/$mercatorOutputsDir/${orgA}-${orgB}";
	    my $pairCacheDir = "$cacheDir/${orgA}-${orgB}";

	    if ($test) {
		$self->runCmd(0,"mkdir $pairOutputDir");
		$self->runCmd(0,"echo hello > $pairOutputDir/${orgA}-${orgB}.align");
		next;
	    }

	    if ($self->cacheHit($orgA, $orgB, $cacheDir, "$workflowDataDir/$mercatorInputsDir", $test)) {
                $self->runCmd($test, "ln -s $pairCacheDir $pairOutputDir");
	    } else {

	        # the strategy here is:
	        #  - set up a tmp dir with input files.
                #  - run mercator in the tmp dir; it will produce output there
                #  - mv the desired output from the tmp dir to the output dir
                #  - remove the tmp dir
                #  - on success, mv the output dir to the cache
                #  - replace the output dir with a link to the cache.

		#  set up tmp dir with input files
		my $pairTmpDir = "$workflowDataDir/$mercatorTmpDir/${orgA}-${orgB}";
		mkdir("$pairTmpDir") || $self->error("Failed making dir $pairTmpDir");
		mkdir("$pairTmpDir/fasta") || $self->error("Failed making dir $pairTmpDir/fasta");
		mkdir("$pairTmpDir/gff") || $self->error("Failed making dir $pairTmpDir/gff");
		$self->runCmd($test, "ln -s $workflowDataDir/$mercatorInputsDir/${orgA}.fasta $pairTmpDir/fasta");
		$self->runCmd($test, "ln -s $workflowDataDir/$mercatorInputsDir/${orgA}.gff $pairTmpDir/gff");
		$self->runCmd($test, "ln -s $workflowDataDir/$mercatorInputsDir/${orgB}.fasta $pairTmpDir/fasta");
		$self->runCmd($test, "ln -s $workflowDataDir/$mercatorInputsDir/${orgB}.gff $pairTmpDir/gff");

		my $draftFlagA = $isDraftHash->{$orgA}? '-d' : '-n';
		my $draftFlagB = $isDraftHash->{$orgB}? '-d' : '-n';

		# run mercator in tmp dir
		my $command = "runMercator -t '($orgA:0.1,$orgB:0.1);' -p $pairTmpDir -c $cndSrcBin -m $mavid $draftFlagA $orgA $draftFlagB $orgB";
		$self->runCmd($test,$command);

                # Check that mercator created some alignments, otherwise move folder to Skipped directory instead of Output.
                if (-d "$pairTmpDir/mercator-output/alignments/1/") {
		  $self->runCmd($test,"mkdir $pairOutputDir");
		  # move selected output from tmp dir to the real output dir
		  $self->runCmd($test,"mv $pairTmpDir/*.align $pairOutputDir");
		  $self->runCmd($test,"mv $pairTmpDir/mercator-output/*.agp $pairOutputDir");
		  $self->runCmd($test,"mv $pairTmpDir/mercator-output/alignments $pairOutputDir");

		  # delete tmp dir
		  $self->runCmd($test,"rm -r $pairTmpDir");

		  # mv the output dir to cache
		  $self->runCmd($test, "mv $pairOutputDir $cacheDir");

		  # and link output dir to cache
		  $self->runCmd($test, "ln -s $pairCacheDir $workflowDataDir/$mercatorOutputsDir");
		} else {
		  # if no alignments, mv to skipped dir
                  my $pairSkippedDir = "$skippedDir/${orgA}-${orgB}";
		  $self->runCmd($test,"mv $pairTmpDir $pairSkippedDir");
		}
	    }
	}
    }
}

sub findOrganismAbbrevs {
    my ($self, $mercatorInputsDir) = @_;
    
    opendir(INPUT, $mercatorInputsDir) or $self->error("Could not open mercator inputs dir '$mercatorInputsDir' for reading.\n");

    my %fastaHash;
    my %gffHash;
    foreach my $file (readdir INPUT){
	next if ($file =~ m/^\./);
	if ($file =~ /(\S+)\.fasta$/) {
	    $fastaHash{$1} = 1;              
	} elsif ($file =~ /(\S+)\.gff$/) { 
	    $gffHash{$1} = 1;              
	} else {
	    $self->error("Unexpected file (neither .gff or .fasta): $mercatorInputsDir/$file");
	}
    }
    $self->error("Mismatched number of .fasta and .gff files in $mercatorInputsDir") unless keys(%gffHash) == keys(%fastaHash);
    $self->error("Empty mercator inputs dir: $mercatorInputsDir") unless keys(%gffHash) > 0;
    return keys(%gffHash);
}

## based on the SO termName of the sequence in the geneattributes table, skip mercator if it is only mito- or api-
sub ifSkipOnSoTermName {
  my ($self, $organismAbbrev, $test) = @_;

  my $tmPrefix = $self->getTuningTablePrefix($organismAbbrev, $test);
  my $sql = "select distinct s.term_name 
                  from apidbtuning.${tmPrefix}sequenceattributes sa, apidbtuning.${tmPrefix}geneattributes ga, SRES.sequenceontology s
                  where sa.na_sequence_id = ga.na_sequence_id and sa.so_id=s.so_id and sa.na_sequence_id in
                  (select distinct na_sequence_id from apidbtuning.${tmPrefix}geneattributes) ";
  my $cmd = "getValueFromTable --idSQL \"$sql\"";

  my $result = $self->runCmd($test, $cmd);
  my @soTermNames = split(/\,/, $result);

  my $ifSkip = "yes";
  foreach my $soTermName (@soTermNames) {
    if ($soTermName eq 'chromosome' || $soTermName eq 'supercontig' || $soTermName eq 'contig' ) {
      $ifSkip = "no";
      last;
    }
  }
  return $ifSkip;
}

sub getIsDraftHash {
    my ($self, $organismAbbrevs, $test) = @_;

    my $hash = {};
    foreach my $organismAbbrev (@$organismAbbrevs) {
	my $tmPrefix = $self->getTuningTablePrefix($organismAbbrev, $test);

	my $sql = "select count(*)
                       from apidbtuning.${tmPrefix}sequenceattributes sa, apidb.organism o, sres.sequenceontology so
                       where so.term_name IN ('chromosome', 'supercontig')
                       and sa.so_id = so.so_id
                       and sa.taxon_id = o.taxon_id
                       and o.abbrev = '$organismAbbrev'";
	my $cmd = "getValueFromTable --idSQL \"$sql\"";
	my $isNotDraftGenome = $self->runCmd($test, $cmd);
	$hash->{$organismAbbrev} = !$isNotDraftGenome;
    }
    return $hash;
}

# we make the bold assumption that nobody has 'touched' the cache dir timestamp, ie, that it
# accurately reflects the age of the cache entry
sub cacheHit {
    my ($self, $orgA, $orgB, $cacheDir, $mercatorInputDir, $test) = @_;
    my $pairName = "${orgA}-${orgB}";

    # -M is a perl built-in function to return a file's relative age.  Smaller is younger.
    my $cacheIsCurrent = -e "$cacheDir/$pairName" 
	&& -M "$cacheDir/$pairName" < -M "$mercatorInputDir/$orgA.fasta" # cache is younger 
	&& -M "$cacheDir/$pairName" < -M "$mercatorInputDir/$orgA.gff"
	&& -M "$cacheDir/$pairName" < -M "$mercatorInputDir/$orgB.fasta"
	&& -M "$cacheDir/$pairName" < -M "$mercatorInputDir/$orgB.gff";
    $self->runCmd($test,"rm -r $cacheDir/$pairName") if (!$cacheIsCurrent && -e "$cacheDir/$pairName");
    return $cacheIsCurrent;
}

1;
