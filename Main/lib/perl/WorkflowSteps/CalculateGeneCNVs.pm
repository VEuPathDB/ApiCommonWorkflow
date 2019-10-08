package ApiCommonWorkflow::Main::WorkflowSteps::CalculateGeneCNVs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $outputDir = $self->getParamValue('outputDir');
  my $fpkmFile = $self->getParamValue('fpkmFile');
  my $geneFootprintFile = $self->getParamValue('geneFootprintFile');
  my $ploidy = $self->getParamValue('ploidy');
  my $sampleName = $self->getParamValue('sampleName');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');

  $outputDir = "$workflowDataDir/$outputDir";
  my $taxonId = $self->getOrganismInfo($test, $organismAbbrev)->getTaxonId();


  my $sql = "with sequence as (
                select gf.source_id as gene_source_id
                , gf.na_feature_id
                , ns.source_id as contig_source_id
                , ns.source_id as sequence_source_id
                , ns.TAXON_ID
                from dots.genefeature gf
                , DOTS.NASEQUENCE ns
                , SRES.ONTOLOGYTERM ot
                where gf.na_sequence_id = ns.na_sequence_id
                and ot.name = 'chromosome'
                and ns.SEQUENCE_ONTOLOGY_ID = ot.ONTOLOGY_TERM_ID
                and ns.taxon_id = $taxonId
                union
                select gf.SOURCE_ID AS gene_source_id
                , gf.na_feature_id
                , contig.source_id as contig_source_id
                , scaffold.SOURCE_ID as chromosome_source_id
                , scaffold.TAXON_ID
                from dots.genefeature gf
                , dots.nasequence contig
                , dots.nasequence scaffold
                , dots.sequencepiece sp
                , SRES.ONTOLOGYTERM ot
                where gf.na_sequence_id = sp.PIECE_NA_SEQUENCE_ID
                and gf.na_sequence_id = contig.na_sequence_id
                and sp.VIRTUAL_NA_SEQUENCE_ID = scaffold.NA_SEQUENCE_ID
                and ot.name = 'chromosome'
                and scaffold.SEQUENCE_ONTOLOGY_ID = ot.ONTOLOGY_TERM_ID
                and scaffold.taxon_id = $taxonId
            )
  
            , orthologs as (
                select gf.na_feature_id, sg.name
                from dots.genefeature gf
                , dots.SequenceSequenceGroup ssg
                , dots.SequenceGroup sg
                , core.TableInfo ti
                where gf.na_feature_id = ssg.sequence_id
                and ssg.sequence_group_id = sg.sequence_group_id
                and ssg.source_table_id = ti.table_id
                and ti.name = 'GeneFeature'
            )

            select s.gene_source_id
            , o.name
            from sequence s
            , orthologs o
            where s.na_feature_id = o.na_feature_id";

  my $cmd = "calculateGeneCNVs --outputDir $outputDir --sampleName $sampleName --fpkmFile $workflowDataDir/$fpkmFile --ploidy $ploidy --sql \"$sql\" --taxonId $taxonId --geneFootPrints $workflowDataDir/$geneFootprintFile";

  if ($undo) {
    $self->runCmd(0, "rm $outputDir/$sampleName\_CNVestimations.tsv") if -e "$outputDir/$sampleName\_CNVestimations.tsv";
    $self->runCmd(0, "rm $outputDir/$sampleName\_geneCNVs.txt") if -e "$outputDir/$sampleName\_geneCNVs.txt";
  }else{
    $self->testInputFile('fpkmFile', "$workflowDataDir/$fpkmFile");
    if ($test) {
        $self->runCmd(0, "echo test > $outputDir/$sampleName\_CNVestimations.tsv");
        $self->runCmd(0, "echo test > $outputDir/$sampleName\_geneCNVs.txt");
    }
    $self->runCmd($test, $cmd);
  }
}

1;
