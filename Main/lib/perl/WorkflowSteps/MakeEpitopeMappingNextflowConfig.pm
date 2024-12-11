package ApiCommonWorkflow::Main::WorkflowSteps::MakeEpitopeMappingNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use warnings;
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
    my ($self, $test, $undo) = @_;

    my $maxForks = 10;
    my $nonTaxaShortPeptideCutoff = 5;

    # DO NOT change these unless you know what you're doing
    my $kmerExact = 5;
    my $kmerExactShort = 2;
    my $kmerNonExact = 3;

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $clusterServer = $self->getSharedConfig('clusterServer');

    my $resultsDirectory = $self->getParamValue("resultsDirectory");

    my $proteinSequenceFile = $self->getParamValue("proteinSequenceFile");

    my $iedbPeptidesTabFile = $self->getParamValue("peptidesTab");

    my $speciesNcbiTaxonId = $self->getParamValue("speciesNcbiTaxonId");
    my $peptideMatchResults = $self->getParamValue("peptideMatchResults");

    my $nextflowConfigFile = $self->getParamValue("nextflowConfigFile");

    my $clusterWorkflowDataDir = $self->getClusterWorkflowDataDir();
    my $executor = $self->getClusterExecutor();
    my $clusterConfigFile = "\$baseDir/conf/${executor}.config";

    if ($undo) {
        $self->runCmd(0, "rm $workflowDataDir/$nextflowConfigFile");
    } else {
        my $nextflowConfig = "$workflowDataDir/$nextflowConfigFile";
        open(F, ">$nextflowConfig") || die "Can't open task prop file '$nextflowConfig' for writing";

        my $configString = <<NEXTFLOW;
params {
  refFasta = "$clusterWorkflowDataDir/$proteinSequenceFile"
  peptidesTab = "$clusterWorkflowDataDir/$iedbPeptidesTabFile"
  taxon = $speciesNcbiTaxonId
  peptideMatchResults = "$peptideMatchResults"
  results = "$clusterWorkflowDataDir/$resultsDirectory"
  nonTaxaShortPeptideCutoff = $nonTaxaShortPeptideCutoff
}
process {
  maxForks = $maxForks

  withName: 'epitopeMapping:smallExactPepMatch:preprocess' {
    ext.kmer_size = $kmerExactShort
    ext.format = "sql"
  }
  withName: 'epitopeMapping:smallExactPepMatch:match' {
    ext.kmer_size = $kmerExactShort
    ext.num_mismatches = 0
  }
  withName: 'epitopeMapping:exactPepMatch:preprocess' {
    ext.kmer_size = $kmerExact
    ext.format = "sql"
  }
  withName: 'epitopeMapping:exactPepMatch:match' {
    ext.kmer_size = $kmerExact
    ext.num_mismatches = 0
  }
  withName: 'epitopeMapping:inexactForTaxaPeptidesPepMatch:preprocess' {
    ext.kmer_size = $kmerNonExact
    ext.format = "pickle"
  }
  withName: 'epitopeMapping:inexactForTaxaPeptidesPepMatch:match' {
    ext.kmer_size = $kmerNonExact
    ext.num_mismatches = 1
  }
}
includeConfig "$clusterConfigFile"

NEXTFLOW

        print F $configString;
        close(F);
    }
}
1;
