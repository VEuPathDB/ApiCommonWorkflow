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

    my $mercatorInputsDir = $self->getParamValue('mercatorInputsDir');
    my $mercatorOutputsDir = $self->getParamValue('mercatorOutputsDir');
    my $mercatorCacheDir = $self->getParamValue('mercatorCacheDir');

    my $cndSrcBin = $self->getConfig('cndSrcBin');
    my $mavid = $self->getConfig('mavidExe');

    my $workflowDataDir = $self->getWorkflowDataDir();

    if ($undo) {
	$self->runCmd(0, "rm -fr $workflowDataDir/$mercatorOutputsDir");
	return;
    }

    my @organismAbbrevs = $self->findOrganismAbbrevs("$workflowDataDir/$mercatorInputsDir"); # tests .fasta and .gff existence

    my $isDraftHash = $self->getIsDraftHash(\@organismAbbrevs);  # hash of 0/1 for each organism

    # create and clean out needed dirs
    $self->runCmd(0, "rm -r $workflowDataDir/$mercatorOutputDir") if -e $mercatorOutputDir;
    mkdir("$workflowDataDir/$mercatorOutputDir");

    $self->runCmd($test, "rm -r $workflowDataDir/$mercatorTmpDir") if -e $pairTmpDir;
    mkdir("$workflowDataDir/$mercatorTmpDir");

    my $cacheDir = "$workflowDataDir/$mercatorCacheDir";
    mkdir("$workflowDataDir/$mercatorCacheDir");


    foreach my $orgA (@organismAbbrevs) {
	foreach my $orgB (@organismAbbrevs) {

	    next unless $orgA > $orgB;  # only do each pair once, and don't do self-self
	    
	    my $pairOuputDir = "$workflowDataDir/$mercatorOutputDir/${orgA}-${orgB}";

	    if ($test) {
		$self->runCmd(0,"mkdir $pairOutputDir");
		$self->runCmd(0,"echo hello > $pairOutputDir/${orgA}-${orgB}.align");
		next;
	    } 

	    if ($self->cacheHit("$orgA, orgB, $workflowDataDir/$mercatorInputsDir, $cacheDir")) {
		$self->runCmd($test, "cp $cacheDir/${orgA}-${orgB} $pairOutputDir");
	    } else {

		#  set up tmp dir with input files
		my $pairTmpDir = "$workflowDataDir/$mercatorTmpDir/${orgA}-${orgB}";
		$self->runCmd($test, "cp $workflowDataDir/$mercatorInputsDir/${orgA}.* $pairTmpDir");
		$self->runCmd($test, "cp $workflowDataDir/$mercatorInputsDir/${orgB}.* $pairTmpDir");

		my $draftFlagA = $isDraftHash->{$orgA}? '-d' : '-n';
		my $draftFlagB = $isDraftHash->{$orgB}? '-d' : '-n';

		my $command = "runMercator  -t '($orgA:0.1,$orgB:0.1);' -p $pairTmpDir -c $cndSrcBin -m $mavid $draftFlagA $orgA $draftFlagB $orgB";
		$self->runCmd($test,$command);

		# move selected output from tmp dir to the real output dir
		$self->runCmd($test,"cp $pairTmpDir/*.align $pairOutputDir");
		$self->runCmd($test,"cp $pairTmpDir/*.agp $pairOutputDir");
		$self->runCmd($test,"cp -r $pairTmpDir/alignments $pairOutputDir");

		# delete tmp dir
		$self->runCmd($test,"rm -r $pairTmpDir");

		# and copy real output dir to cache
		$self->runCmd($test, "cp $pairOutputDir $cacheDir");
	    }
	}
    }
}

sub findOrganismAbbrevs {
    my ($self, $mercatorInputsDir) = @_;
    
    opendir(INPUT, $mercatorInputsDir) or $self->error("Could not open mercator inputs dir '$mercatorInputsDir' for reading.\n");

    my %hash;
    my $gffCount;
    foreach my $file (readdir INPUT){
	next if ($file =~ m/^\./);
	if ($file =~ /(\S+)\.fasta$/) {
	    $hash{$1} = 1;               # remember this orgAbbrev
	} elsif ($file =~ /(\S+)\.gff$/) { 
	    $hash{$1} || $self->error("No matching .fasta file for $mercatorInputsDir/$file");
	    $gffCount++;
	} else {
	    $self->error("Unexpected file (neither .gff or .fasta): $mercatorInputsDir/$file");
	}
    }
    $self->error("Mismatched number of .fasta and .gff files in $mercatorInputsDir") unless $gffCount == keys(%hash);
    $self->error("Empty mercator inputs dir: $mercatorInputsDir") unless $gffCount;
    return keys(%hash);
}

sub getIsDraftHash {
    my ($self, $organismAbbrevs) = @_;

    my $hash = {};
    foreach my $organismAbbrev (@$organismAbbrevs) {
	$hash->{$organismAbbrev} = $self->getOrganismInfo($organismAbbrev)->getIsDraftGenome();
    }
    return $hash;
}

# we make the bold assumption that nobody has 'touched' the cache dir timestamp, ie, that it
# accurately reflects the age of the cache entry
sub cacheHit {
    my ($self, $orgA, $orgB, $cacheDir, $mercatorInputDir) = @_;
    my $pairName = "${orgA}-${orgB}";
    return -e "$cacheDir/$pairName" 
	&& -M "$cacheDir/$pairName" < "$mercatorInputDir/$orgA.fasta" # cache is younger 
	&& -M "$cacheDir/$pairName" < "$mercatorInputDir/$orgA.gff"
	&& -M "$cacheDir/$pairName" < "$mercatorInputDir/$orgB.fasta"
	&& -M "$cacheDir/$pairName" < "$mercatorInputDir/$orgB.gff"
}

sub getConfigDeclaration {
    return (
	# [name, default, description]

	);
}
