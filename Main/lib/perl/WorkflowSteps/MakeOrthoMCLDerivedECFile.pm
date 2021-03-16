package ApiCommonWorkflow::Main::WorkflowSteps::MakeOrthoMCLDerivedECFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $gusConfigFile= "$ENV{GUS_HOME}/config/gus.config";

  my $genesByTaxonOutputFile = $self->getParamValue('genesByTaxonOutputFile');
  my $genesByEcOutputFile = $self->getParamValue('genesByEcOutputFile');

  my $allOrthoGrpsOutputFile = $self->getParamValue('allOrthoGrpsOutputFile');
  my $orthoSeqsWithECsOutputFile = $self->getParamValue('orthoSeqsWithECsOutputFile');

  my $orthoEupathOutputFile = $self->getParamValue('orthoEupathOutputFile');
  my $finalOutputFile = $self->getParamValue('finalOutputFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmdGenesByTaxonAndEcNumber = "getGenesByTaxonAndEcNumber.pl --gusConfigFile $gusConfigFile --outputGenesByTaxon $workflowDataDir/$genesByTaxonOutputFile --outputGenesByEcNumber $workflowDataDir/$genesByEcOutputFile";

  my $cmdOrthoMCL = "getDataFromOrthoMCL.pl --outputAllOrthoGrps $workflowDataDir/$allOrthoGrpsOutputFile --outputOrthoSeqsWithECs $workflowDataDir/$orthoSeqsWithECsOutputFile";

  my $cmdAddEupathECToOmcl = "addEupathECToOmcl.pl -orthoFile $workflowDataDir/$allOrthoGrpsOutputFile -eupathFile $workflowDataDir/$genesByEcOutputFile --os $workflowDataDir/$orthoSeqsWithECsOutputFile > $workflowDataDir/$orthoEupathOutputFile";
  
  my $cmdPropagateOrthoEcToEuPath = "propagateOrthoEcToEuPath.pl -o $workflowDataDir/$orthoEupathOutputFile -e $workflowDataDir/$genesByTaxonOutputFile --lf > $workflowDataDir/$finalOutputFile";


  if($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$genesByTaxonOutputFile");    
    $self->runCmd(0, "rm -f $workflowDataDir/$genesByEcOutputFile");    
    $self->runCmd(0, "rm -f $workflowDataDir/$allOrthoGrpsOutputFile");    
    $self->runCmd(0, "rm -f $workflowDataDir/$orthoSeqsWithECsOutputFile");    
    $self->runCmd(0, "rm -f $workflowDataDir/$allOrthoGrpsOutputFile.tmp");    
    $self->runCmd(0, "rm -f $workflowDataDir/$orthoSeqsWithECsOutputFile.tmp");    
    $self->runCmd(0, "rm -f $workflowDataDir/$orthoEupathOutputFile");    
    $self->runCmd(0, "rm -f $workflowDataDir/$finalOutputFile");
    $self->runCmd(0, "rm -f $workflowDataDir/OrthoMCLDerivedEC/*.log");    
  } else {
    $self->runCmd(0,"echo test > $workflowDataDir/$finalOutputFile") if ($test);
    $self->runCmd($test, $cmdGenesByTaxonAndEcNumber);
    $self->runCmd($test, $cmdOrthoMCL);
    $self->runCmd($test, $cmdAddEupathECToOmcl);
    $self->runCmd($test, $cmdPropagateOrthoEcToEuPath);
  } 
} 

1;
