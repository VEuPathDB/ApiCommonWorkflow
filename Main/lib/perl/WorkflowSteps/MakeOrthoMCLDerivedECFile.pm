package ApiCommonWorkflow::Main::WorkflowSteps::MakeOrthoMCLDerivedECFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $gusConfigFile= "$ENV{GUS_HOME}/config/gus.config";
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmdGenesByTaxonAndEcNumber = "getGenesByTaxonAndEcNumber.pl --gusConfigFile $gusConfigFile --outputGenesByTaxon $workflowDataDir/GenesByTaxon_summary.txt --outputGenesByEcNumber $workflowDataDir/GenesByEcNumber_summary.txt";

  my $cmdOrthoMCL = "getDataFromOrthoMCL.pl --outputAllOrthoGrps $workflowDataDir/AllOrthoGrps.txt --outputOrthoSeqsWithECs $workflowDataDir/OrthoSeqsWithECs.txt";

  my $cmdAddEupathECToOmcl = "addEupathECToOmcl.pl -orthoFile $workflowDataDir/AllOrthoGrps.txt -eupathFile $workflowDataDir/GenesByEcNumber_summary.txt --os $workflowDataDir/OrthoSeqsWithECs.txt > $workflowDataDir/OrthoGrpsWithEupathNewAndAdded.txt";
  
  my $cmdPropagateOrthoEcToEuPath = "propagateOrthoEcToEuPath.pl -o $workflowDataDir/OrthoGrpsWithEupathNewAndAdded.txt -e $workflowDataDir/GenesByTaxon_summary.txt --lf > $workflowDataDir/ec.txt";


  if($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/GenesByTaxon_summary.txt");    
    $self->runCmd(0, "rm -f $workflowDataDir/GenesByEcNumber_summary.txt");    
    $self->runCmd(0, "rm -f $workflowDataDir/OrthoSeqsWithECs.txt");    
    $self->runCmd(0, "rm -f $workflowDataDir/AllOrthoGrps.txt");    
  } else {
    $self->runCmd($test, $cmdGenesByTaxonAndEcNumber);
    $self->runCmd($test, $cmdOrthoMCL);
    $self->runCmd($test, $cmdAddEupathECToOmcl);
    $self->runCmd($test, $cmdPropagateOrthoEcToEuPath);
  } 
} 

1;
