#!/usr/bin/perl

package ApiCommonWorkflow::Main::WorkflowSteps::MakeLongReadRnaSeqNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use warnings;
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
sub run {

my ($self, $test, $undo) = @_;
my $workflowDataDir = $self->getWorkflowDataDir();

my $splitChunk = 10000; 
my $annotation = join("/", $workflowDataDir, $self->getParamValue("annotation"));
my $reference =  join("/", $workflowDataDir, $self->getParamValue("reference"));
#my $reads = $self->getParamValue("parentDataDir");
my $reads =  join("/", $workflowDataDir, $self->getParamValue("FastqFiles"));
my $platform = $self->getParamValue("platform");
my $build = $self->getParamValue("databaseBuild");
my $annotationName = $self->getParamValue("databaseName");
my $results = join("/", $workflowDataDir, $self->getParamValue("clusterResultDir"));
my $databaseDir = join("/", $workflowDataDir, $self->getParamValue("databaseDir"));
my $database = join("/",$workflowDataDir, $self->getParamValue("databaseDir"), $self->getParamValue("talonDataBase"));
my $local = 'true';
my $configPath = join("/", $workflowDataDir, $self->getParamValue("configFileName"));


if ($undo) {
    $self->runCmd(0,"rm -rf $configPath");
  } else {

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
    local = $local
}

singularity {
    enabled = true
} 
 ";

 close(F);
  }
}
1;
