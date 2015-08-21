package ApiCommonWorkflow::Main::WorkflowSteps::RunOrthoMCLDerivedECNumbers;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();

  if($undo) {
  }
  else {

    if ($test) {
      $self->runCmd(0,"echo test > $workflowDataDir/test.txt");
    }

    $self->runCmd($test, "getGenesByTaxonAndEcNumber.pl -o $workflowDataDir");

    $self->runCmd($test, "getDataFromOrthoMcl.pl -o $workflowDataDir");

    $self->runCmd($test, "addEupathECToOmcl.pl -orthoFile $workflowDataDir/AllOrthoGrps.txt -eupathFile $workflowDataDir/GenesByEcNumber_summary.txt --os $workflowDataDir/OrthoSeqsWithECs.txt > $workflowDataDir/OrthoGrpsWithEupathNewAndAdded.txt");

    $self->runCmd($test, "propagateOrthoEcToEuPath.pl -o $workflowDataDir/OrthoGrpsWithEupathNewAndAdded.txt -e $workflowDataDir/GenesByTaxon_summary.txt --lf > $workflowDataDir/ec.txt");

  } 
}

1;
