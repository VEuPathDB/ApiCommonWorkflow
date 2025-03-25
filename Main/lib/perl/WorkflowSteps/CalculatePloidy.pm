package ApiCommonWorkflow::Main::WorkflowSteps::CalculatePloidy;

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
  my $gusConfigFile = $self->getParamValue('gusConfigFile');
  $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";

  my $taxonId = $self->getOrganismInfo($test, $organismAbbrev, $gusConfigFile)->getTaxonId(); 

  $outputDir = "$workflowDataDir/$outputDir";

  my $cmd = "calculatePloidy --outputDir $outputDir --sampleName $sampleName --fpkmFile $workflowDataDir/$fpkmFile --ploidy $ploidy --taxonId $taxonId --geneFootprints $workflowDataDir/$geneFootprintFile";

  if ($undo) {
    $self->runCmd(0, "rm $outputDir/$sampleName\_Ploidy.txt");
  }else{
    $self->testInputFile('fpkmFile', "$workflowDataDir/$fpkmFile");
    if ($test) {
        $self->runCmd(0, "echo test > $outputDir/$sampleName\_Ploidy.txt");
    }
    $self->runCmd($test, $cmd);
  }
}

1;
