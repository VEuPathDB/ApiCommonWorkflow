package ApiCommonWorkflow::Main::WorkflowSteps::MakeLongReadRnaSeqNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use warnings;
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {



my ($self, $test, $undo) = @_;
#my $workflowDataDir = $self->getWorkflowDataDir();
my $workflowDataDir = $self->getClusterWorkflowDataDir();

my $isSRA = $self->getParamValue("isSRA");
my $splitChunk = $self->getParamValue("splitChunck"); 
my $annotation = join("/", $workflowDataDir, $self->getParamValue("annotation"));
my $reference =  join("/", $workflowDataDir, $self->getParamValue("reference"));
my $reads =  join("/", $workflowDataDir, $self->getParamValue("dataSource"));
my $platform = $self->getParamValue("platform");
my $build = $self->getParamValue("databaseBuild");
my $annotationName = $self->getParamValue("databaseName");
my $results = join("/", $workflowDataDir, $self->getParamValue("clusterResultDir"));
my $databaseDir = join("/", $workflowDataDir, $self->getParamValue("databaseDir"));
my $database = join("/",$workflowDataDir, $self->getParamValue("databaseDir"), $self->getParamValue("talonDataBase"));
my $maxFracA = $self->getParamValue("maxFracA");
my $minCount = $self->getParamValue("minCount");
my $minDatasets = $self->getParamValue("minDatasets");
my $configPath = join("/", $workflowDataDir, $self->getParamValue("configFileName"));


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
    referenceAnnotation = \"$annotation\"
    reference = \"$reference\"
    sraAccession  = \"$sraList\"
    platform = \"$platform\"
    build = \"$build\"
    annotationName = \"$annotationName\"
    results = \"$results\"
    databaseDir = \"$databaseDir\"
    database = \"$database\"
    local = false
    maxFracA = $maxFracA
    minCount = $minCount
    minDatasets = $minDatasets
}

singularity {
    enabled = true
    autoMounts = true
} 
 ";

 close(F);
 } else{
  open(F, ">", $configPath) or die "$! :Can't open config file '$configPath' for writing";
 print F
 " 
 params {
    splitChunk = $splitChunk
    referenceAnnotation = \"$annotation\"
    reference = \"$reference\"
    reads = \"$reads\"
    platform = \"$platform\"
    build = \"$build\"
    annotationName = \"$annotationName\"
    results = \"$results\"
    databaseDir = \"$databaseDir\"
    database = \"$database\"
    local = true
    maxFracA = $maxFracA
    minCount = $minCount
    minDatasets = $minDatasets
}

singularity {
    enabled = true
    autoMounts = true
} 
 ";

 close(F)

  }
 }
}
1;
