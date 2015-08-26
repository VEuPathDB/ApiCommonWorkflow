package ApiCommonWorkflow::Main::WorkflowSteps::MakeOrthoMCLDerivedECFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $gusConfigFile= "$ENV{GUS_HOME}/config/gus.config";
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmdGenesByTaxonAndEcNumber = "getGenesByTaxonAndEcNumber.pl --gusConfigFile $gusConfigFile --outputGenesByTaxon $workflowDataDir/GenesByTaxon_summary.txt --outputGenesByEcNumber $workflowDataDir/GenesByEcNumber_summary.txt";

  my $cmdOrthoMCL = "getDataFromOrthoMcl.pl --outputAllOrthoGrps $workflowDataDir/AllOrthoGrps.txt --outputOrthoSeqsWithECs $workflowDataDir/OrthoSeqsWithECs.txt";

  my $cmdAddEupathECToOmcl = "addEupathECToOmcl.pl -orthoFile $workflowDataDir/AllOrthoGrps.txt -eupathFile $workflowDataDir/EuPathDBGenesWithEC.tsv  --os $workflowDataDir/OrthoSeqsWithECs.txt > $workflowDataDir/OrthoGrpsWithEupathNewAndAdded.txt";
  
  my $cmdPropagateOrthoEcToEuPath = "propagateOrthoEcToEuPath.pl -o $workflowDataDir/OrthoGrpsWithEupathNewAndAdded.txt -e $workflowDataDir/AllEuPathGenes.tsv --lf > $workflowDataDir/ec.txt ;"


  if($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/GenesByTaxon_summary.txt");    
    $self->runCmd(0, "rm -f $workflowDataDir/GenesByEcNumber_summary.txt");    
  } else {
    $self->runcmd($test, $cmdGenesByTaxonAndEcNumber);
    $self->runcmd($test, $cmdOrthoMCL);
    $self->runcmd($test, $cmdAddEupathECToOmcl);
    $self->runcmd($test, $cmdPropagateOrthoEcToEuPath);
  } 
} 

1;
