package ApiCommonWorkflow::Main::WorkflowSteps::MakeBulkRnaSeqNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use warnings;
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
 my ($self, $test, $undo) = @_;

 #my $workflowDataDir = $self->getWorkflowDataDir();
 my $workflowDataDir = $self->getClusterWorkflowDataDir();
 my $dir = join("/", $workflowDataDir, $self->getParamValue("analysisDir")); 

 open(INTRON, "$dir/maxIntronLen") or die "Cannot read max intron len from $dir/maxIntronLen\n$!\n";

# read the file, and push every line into an array
 my @lines;
 while (my $line = <INTRON>) {
    chomp $line;
    push (@lines,  $line);
 }

 if (scalar @lines != 1) {
    die "File $dir/maxIntronLen should only contain one line\n";
 }

 my $maxIntronLen = $lines[0];

 my $configPath = join("/", $workflowDataDir, $self->getParamValue("configFileName"));
 my $splitChunk = 1000000;                                                                                                                      
 my $reads =  join("/", $workflowDataDir, $self->getParamValue("dataSource"));
 my $isPaired = $self->getParamValue("isPaired");
 my $isStranded = $self->getParamValue("isStrandSpecific");
 my $isCds = $self->getParamValue("isCDS");
 my $results = join("/", $workflowDataDir, $self->getParamValue("clusterResultDir"));
 my $annotation = join("/", $workflowDataDir, $self->getParamValue("annotation"));
 my $hisat2Index = join("/", $workflowDataDir, $self->getParamValue("hisat2Index"));
 my $createIndex = "false";
 my $organismAbbv = $self->getParamValue("organismAbbrev");
 my $isSRA = $self->getParamValue("isSRA");


  if ($undo) {
    $self->runCmd(0,"rm -rf $configPath");
  } else {
  
  if ($isSRA eq "true") {
    my $sraList = join("/", $reads, 'sraSampleList.tsv'); 
    open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";

    print F
 " 
 params {
    splitChunk = $splitChunk
    sraAccession = \"$sraList\"
    isPaired = $isPaired
    isStranded = $isStranded
    intronLength = $maxIntronLen
    isCds = $isCds
    results = \"$results\"
    annotation = \"$annotation\"
    hisat2Index = \"$hisat2Index\"
    createIndex = $createIndex
    organismAbbv = \"$organismAbbv\"
    local = false
}
singularity {
    enabled = true
    autoMounts = true
} 
 ";

 close(F);

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
    local = true
}
singularity {
    enabled = true
    autoMounts = true
} 
 ";

 close(F);
    }

  }
}
1;
