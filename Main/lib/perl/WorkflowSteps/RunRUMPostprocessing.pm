package ApiCommonWorkflow::Main::WorkflowSteps::RunRUMPostprocessing;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  # reads files in mainResultDir and produces more files in there (and deletes some too).

  my $genomeFastaFile = $self->getParamValue('genomeFastaFile');
  my $transcriptFastaFile = $self->getParamValue('transcriptFastaFile');
  my $geneAnnotationFile = $self->getParamValue('geneAnnotationFile');
  my $mainResultDir = $self->getParamValue('mainResultDir');
  my $createJunctionsFile = $self->getBooleanParamValue('createJunctionsFile');
  my $strandSpecific = $self->getBooleanParamValue('strandSpecific');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $haveTranscripts = -e "$workflowDataDir/$transcriptFastaFile"? "--haveTranscripts" : "";
  my $createJunctions = $createJunctionsFile? "--createJuctions" : "";
  my $ss = $strandSpecific? "--strandSpecific" : "";

  my $cmd= "postProcessRUMTask --genomeFastaFile $workflowDataDir/$genomeFastaFile --geneAnnotationFile $workflowDataDir/$geneAnnotationFile --mainResultDir $workflowDataDir/$mainResultDir $haveTranscripts $createJunctions $ss";

  if($undo){
      # can't undo this step.  must undo cluster task
  }else{
      if ($test) {
	  $self->testInputFile('genomeFastaFile', "$workflowDataDir/$genomeFastaFile");
	  $self->testInputFile('geneAnnotationFile', "$workflowDataDir/$geneAnnotationFile");
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

