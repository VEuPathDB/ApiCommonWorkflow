package ApiCommonWorkflow::Main::WorkflowSteps::MakeBulkRnaSeqNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use warnings;
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
 my ($self, $test, $undo) = @_;

 my $workflowDataDir = $self->getClusterWorkflowDataDir();
 my $dir = join("/", $workflowDataDir, $self->getParamValue("inputDir")); 

 open(INTRON, "$dir/maxIntronLen") or die "Cannot read max intron len from $dir/maxIntronLen\n$!\n";

# read the file, and push every line into an array
 my @lines;
 while (my $line = <INTRON>) {
    chomp $line;
    push (@lines,  $line);
 }

# there should only be one line in this file, so check that this is true
 if (scalar @lines != 1) {
    die "File $dir/maxIntronLen should only contain one line\n";
 }

# if it is true, read the first line - this is your intron length value
# it may be worth adding an additional check that this is numeric
 my $maxIntronLen = $lines[0];

 my $configPath = join("/", $workflowDataDir, $self->getParamValue("configFileName"));
 my $splitChunk = 1000000;                                                                                                                      
 my $reads =  join("/", $workflowDataDir, $self->getParamValue("FastqFiles"));
 my $isPaired = $self->getParamValue("isPaired");
 my $isStranded = $self->getParamValue("isStrandSpecific");
 my $isCds = $self->getParamValue("isCDS");
 my $results = join("/", $workflowDataDir, $self->getParamValue("clusterResultDir"));
 my $annotation = join("/", $workflowDataDir, $self->getParamValue("annotation"));
 my $hisat2Index = join("/", $workflowDataDir, $self->getParamValue("hisat2Index"));
 my $createIndex = "false";
 my $organismAbbv = $self->getParamValue("organismAbbrev");
 my $islocal = $self->getParamValue("isLocal");


  if ($undo) {
    $self->runCmd(0,"rm -rf $configPath");
  } else {
    open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";

    print F
 " 
 params {
    splitChunk = $splitChunk
    reads = \"$reads\"
    isPaired = $isPaired
    isStranded = $isStranded
    intronLength = $maxIntronLen
    isCds = $isCds
    results = \"$results\"
    annotation = \"$annotation\"
    hisat2Index = \"$hisat2Index\"
    createIndex = $createIndex
    organismAbbv = \"$organismAbbv\"
    local = $islocal
}
singularity {
    enabled = true
    autoMounts = true
} 
 ";

 close(F);

	}
}
1;
