package ApiCommonWorkflow::Main::WorkflowSteps::MakeGtfForGuidedCufflinks;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    # get parameter values
    my $workflowDataDir = $self->getWorkflowDataDir();
    my $gtfDir = $self->getParamValue("gtfDir");
    my $outputFile = $self->getParamValue("outputFile");
    my $project = $self->getParamValue("project");
    my $organismAbbrev = $self->getParamValue("organismAbbrev");

    my $taxonId = $self->getOrganismInfo($test, $organismAbbrev)->getTaxonId();
    my $sql = "select ns.source_id as chr,
               gf.source_id as gene_id,
               ef.source_id as exon_id,
               tr.source_id as transcript_id,
               l.start_min,
               l.end_max,
               decode(l.is_reversed, 1, '-', 0, '+', 'err') as strand,
               ef.coding_start,
               ef.coding_end,
               mod(3-mod((select nvl(sum(greatest(ef2.coding_start, ef2.coding_end) - least(ef2.coding_start, ef2.coding_end) + 1), 0)
                    from dots.exonfeature ef2
                    where parent_id = ef.parent_id
                    and order_number < ef.order_number), 3), 3) as phase
               from sres.taxon t,
               dots.nasequence ns,
               dots.genefeature gf,
               dots.exonfeature ef,
               dots.transcript tr,
               dots.nalocation l
               where t.taxon_id = $taxonId
               and ns.taxon_id = t.taxon_id
               and gf.na_sequence_id = ns.na_sequence_id
               and ef.parent_id = gf.na_feature_id
               and tr.parent_id = gf.na_feature_id
               and l.na_feature_id = ef.na_feature_id
               order by ns.source_id, l.start_min"; 
    
    my $cmd = "makeGtfForGuidedCufflinks.pl --outputFile $workflowDataDir/$gtfDir/$outputFile --SQL \"$sql\" --project $project";

    if ($undo) {
        $self->runCmd(0, "rm -f $workflowDataDir/$gtfDir/$outputFile");
    }else{
        if($test) {
            $self->runCmd(0, "echo test > $workflowDataDir/$gtfDir/$outputFile");
        }
        $self->runCmd($test, $cmd);
    }
}

1; 
