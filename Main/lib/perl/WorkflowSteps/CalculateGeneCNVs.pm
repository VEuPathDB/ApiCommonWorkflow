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
  my $ploidy = $self->getParamValue('ploidy');
  my $sampleName = $self->getParamValue('sampleName');
  my $organismAbbrev = $self->getParamValue('organismAbbrev');

  my $outputDir = "$workflowDataDir/$outputDir";
  my $taxonId = $self->getOrganismInfo($test, $organismAbbrev)->getTaxonId();

  my $sql = "select gf.source_id as geneid,
             sg.name as orthomcl_id
             from sres.taxon t,
             dots.nasequence ns,
             dots.genefeature gf,
             dots.sequencesequencegroup ssg,
             dots.sequencegroup sg
             where t.taxon_id = $taxonId
             and ns.taxon_id = t.taxon_id
             and gf.na_sequence_id = ns.na_sequence_id
             and ssg.source_table_id = 232
             and ssg.sequence_id = gf.na_feature_id
             and sg.sequence_group_id = ssg.sequence_group_id
             order by gf.source_id";

  my $cmd = "calculateGeneCNVs --outputDir $outputDir --sampleName $sampleName --fpkmFile $fpkmFile --ploidy $ploidy --sql $sql";

  if ($undo) {
    $self->runCmd(0, "rm $outputDir/$sampleName\_CNVestimations.tsv");
    $self->runCmd(0, "rm $outputDir/$sampleName\_geneCNVs.txt");
  }else{
    $self->testInputFile('fpkmFile', $fpkmFile);
    if ($test) {
        $self->runCmd(0, "echo test > $outputDir/$sampleName\_CNVestimations.tsv");
        $self->runCmd(0, "echo test > $outputDir/$sampleName\_geneCNVs.txt");
    }
    $self->runCmd($test, $cmd);
  }
}

1;
