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


    foreach my $orgA (@organismAbbrevs) {
	foreach my $orgB (@organismAbbrevs) {

	    next unless $orgA > $orgB;  # only do each pair once, and don't do self-self

	    my $pairOutputDir = "$workflowDataDir/$mercatorOutputsDir/${orgA}-${orgB}";

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
		mkdir("$pairTmpDir") || $self->error("Failed making dir $pairTmpDir");
		mkdir("$pairTmpDir/fasta") || $self->error("Failed making dir $pairTmpDir/fasta");
		mkdir("$pairTmpDir/gff") || $self->error("Failed making dir $pairTmpDir/gff");

		$self->runCmd($test, "cp $workflowDataDir/$mercatorInputsDir/${orgA}.fasta $pairTmpDir/fasta");
		$self->runCmd($test, "cp $workflowDataDir/$mercatorInputsDir/${orgA}.gff $pairTmpDir/gff");
		$self->runCmd($test, "cp $workflowDataDir/$mercatorInputsDir/${orgB}.fasta $pairTmpDir/fasta");
		$self->runCmd($test, "cp $workflowDataDir/$mercatorInputsDir/${orgB}.gff $pairTmpDir/gff");

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

sub getIsDraftHash {
    my ($self, $organismAbbrevs, $test) = @_;

    my $hash = {};
    foreach my $organismAbbrev (@$organismAbbrevs) {
	$hash->{$organismAbbrev} = $self->getOrganismInfo($test,$organismAbbrev)->getIsDraftGenome();
    }
    return $hash;
}

# we make the bold assumption that nobody has 'touched' the cache dir timestamp, ie, that it
# accurately reflects the age of the cache entry
sub cacheHit {
    my ($self, $orgA, $orgB, $cacheDir, $mercatorInputDir, $test) = @_;
    my $pairName = "${orgA}-${orgB}";

    # -M is a perl built-in function to return a file's age
    my $cacheIsCurrent = -e "$cacheDir/$pairName" 
	&& -M "$cacheDir/$pairName" < "$mercatorInputDir/$orgA.fasta" # cache is younger 
	&& -M "$cacheDir/$pairName" < "$mercatorInputDir/$orgA.gff"
	&& -M "$cacheDir/$pairName" < "$mercatorInputDir/$orgB.fasta"
	&& -M "$cacheDir/$pairName" < "$mercatorInputDir/$orgB.gff";
    $self->runCmd($test,"rm -r $cacheDir/$pairName") if !$cacheIsCurrent;
    return $cacheIsCurrent;
}

sub getConfigDeclaration {
    return (
	# [name, default, description]

	);
}
