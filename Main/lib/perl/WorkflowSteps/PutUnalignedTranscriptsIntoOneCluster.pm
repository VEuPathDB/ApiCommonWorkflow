package ApiCommonWorkflow::Main::WorkflowSteps::PutUnalignedTranscriptsIntoOneCluster;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $allClustersOutputFile = $self->getParamValue('allClustersOutputFile');
  my $alignedClustersFile = $self->getParamValue('alignedClustersFile');
  my $repeatMaskErrFile = $self->getParamValue('repeatMaskErrFile');
  my $useTaxonHierarchy = $self->getParamValue('useTaxonHierarchy');
  my $parentNcbiTaxonId = $self->getParamValue('parentNcbiTaxonId');
  my $targetNcbiTaxId = $self->getParamValue('targetNcbiTaxId');

  my $workflowDataDir = $self->getWorkflowDataDir();
  
  my $taxonId = $self->getTaxonIdFromNcbiTaxId($test,$parentNcbiTaxonId);
  my $taxonIdList = $self->getTaxonIdList($test, $taxonId, $useTaxonHierarchy);
  my $targetTaxonId = $self->getTaxonIdFromNcbiTaxId($test,$targetNcbiTaxId);

  my $cmd = "getUnalignedAssemSeqIds --alignedClustersFile $workflowDataDir/$alignedClustersFile --outputFile $workflowDataDir/$allClustersOutputFile --repeatMaskErrFile $workflowDataDir/$repeatMaskErrFile --taxonIdList $taxonIdList --targetTaxonId $targetTaxonId";

  if($undo){
      $self->runCmd(0,"rm -f  $workflowDataDir/$allClustersOutputFile");
  }else{
      if ($test) {
	  $self->testInputFile('alignedClustersFile', "$workflowDataDir/$alignedClustersFile");
	  $self->testInputFile('repeatMaskErrFile', "$workflowDataDir/$repeatMaskErrFile");
	  $self->runCmd(0, "echo test > $workflowDataDir/$allClustersOutputFile");
      }else{
	  $self->runCmd($test, $cmd);
      }
  }
  
}


sub getParamsDeclaration {
  return (
     'alignedClustersFile',
     'allClustersOutputFile',
     'repeatMaskErrFile',
    );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


