package ApiCommonWorkflow::Main::WorkflowSteps::RunRUMPostprocessing;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  # reads files in mainResultDir and produces more files in there (and deletes some too).

  my $genomeFastaFile = $self->getParamValue('genomeFastaFile');
  my $geneAnnotationFile = $self->getParamValue('geneAnnotationFile');
  my $transcriptsFastaFile = $self->getParamValue('transcriptFastaFile');
  my $strandSpecific = $self->getBooleanParamValue('strandSpecific');
  my $createJunctionsFile = $self->getBooleanParamValue('createJunctionsFile');
  my $mainResultDir = $self->getParamValue('mainResultDir');
  my $topLevelSeqSizeFile = $self->getParamValue('topLevelSeqSizeFile');
  my $readsFile = $self->getParamValue('readsFile');
  my $qualFile = $self->getParamValue('qualFile');
  my $createBigWigFile = $self->getBooleanParamValue('createBigWigFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $haveTranscripts = -e "$workflowDataDir/$transcriptsFastaFile"? "--haveTranscripts" : "";
  my $createJunctions = $createJunctionsFile? "--createJunctions" : "";
  my $ss = $strandSpecific? "--strandSpecific" : "";
  my $createBigWig = $createBigWigFile? "--createBigWigFile" : "";
  my $cmd= "postProcessRUMTask --genomeFastaFile $workflowDataDir/$genomeFastaFile --geneAnnotationFile ".(-e "$workflowDataDir/$geneAnnotationFile"? "$workflowDataDir/$geneAnnotationFile" : "none")." --mainResultDir $workflowDataDir/$mainResultDir $haveTranscripts $createJunctions $ss $createBigWig --readsFile $workflowDataDir/$readsFile --qualFile $workflowDataDir/$qualFile --topLevelSeqSizeFile $workflowDataDir/$topLevelSeqSizeFile";

  if($undo){
      # can't undo this step.  must undo cluster task
  }else{
      if ($test) {
	  $self->testInputFile('genomeFastaFile', "$workflowDataDir/$genomeFastaFile");
      }else{
	  $self->runCmd($test, $cmd);
      }
  }
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

