package ApiCommonWorkflow::Main::WorkflowSteps::MakeNormalisedCoverageTrack;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    #get parameter values
    my $coverageFile = $self->getParamValue("coverageFile");
    my $ploidy = $self->getParamValue("ploidy");
    my $sampleName = $self->getParamValue("sampleName");
    my $outputDir = $self->getParamValue("outputDir"); #may rename
    my $chromSizesFile = $self->getParamValue("chromSizesFile");
    my $organismAbbrev = $self->getParamValue("organismAbbrev");
    my $workflowDataDir = $self->getWorkflowDataDir();

    my $taxonId = $self->getOrganismInfo($test, $organismAbbrev)->getTaxonId();
    
    # This statement will only return chromosomes.
    my $SQL = "select ens.source_id
               from sres.sequenceontology so,
               dots.externalnasequence ens
               where so.so_id = 'SO:0000340'
               and so.sequence_ontology_id = ens.sequence_ontology_id
               and ens.taxon_id = $taxonId";

    my $cmd = "makeNormalisedCoverageTrack --coverageFile $workflowDataDir/$coverageFile --ploidy $ploidy --sampleName $sampleName --outputDir $workflowDataDir/$outputDir --chromSizesFile $workflowDataDir/$chromSizesFile --SQL \"$SQL\"";

    if ($undo) {
        $self->runCmd(0, "rm -f $workflowDataDir/$outputDir/$sampleName.bw");
    }else{
        $self->testInputFile('coverageFile', "$workflowDataDir/$coverageFile");
        if($test) {
            $self->runCmd(0, "echo test > $workflowDataDir/$outputDir/$sampleName.bw");
        }
        $self->runCmd($test, $cmd);
    }
}

1; 
