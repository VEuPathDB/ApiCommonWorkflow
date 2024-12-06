package ApiCommonWorkflow::Main::WorkflowSteps::MakeEpitopeMappingNextflowConfig;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use warnings;
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
    my ($self, $test, $undo) = @_;

    my $chunkSize = 500;
    my $maxForks = 10;

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $clusterServer = $self->getSharedConfig('clusterServer');

    my $resultsDirectory = $self->getParamValue("resultsDirectory");

    my $proteinSequenceFile = $self->getParamValue("proteinSequenceFile");

    my $iedbPeptidesTabFile = $self->getParamValue("peptidesTab");

    my $speciesNcbiTaxonId = $self->getParamValue("speciesNcbiTaxonId");
    my $peptideMatchResults = $self->getParamValue("peptideMatchResults");
    my $peptidesFilteredBySpeciesFasta = $self->getParamValue("peptidesFilteredBySpeciesFasta");
    my $peptideMatchBlastCombinedResults = $self->getParamValue("peptideMatchBlastCombinedResults");

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
   peptidesFilteredBySpeciesFasta = "$peptidesFilteredBySpeciesFasta"
   peptideMatchBlastCombinedResults = "$peptideMatchBlastCombinedResults"
   chunkSize = $chunkSize
   results = "$clusterWorkflowDataDir/$resultsDirectory"
}

process {
    maxForks = $maxForks
}

includeConfig "$clusterConfigFile"

NEXTFLOW

        print F $configString;
        close(F);
    }
}
1;
