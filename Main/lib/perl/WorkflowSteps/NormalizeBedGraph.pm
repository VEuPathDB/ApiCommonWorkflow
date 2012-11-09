package ApiCommonWorkflow::Main::WorkflowSteps::NormalizeBedGraph;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputDir = $self->getParamValue('inputDir');
  my $topLevelSeqSizeFile = $self->getParamValue('topLevelSeqSizeFile');
  my $strandSpecific = $self->getBooleanParamValue('strandSpecific');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $ss = $strandSpecific? "--strandSpecific" : "";
  my $cmd= "--inputDir $workflowDataDir/$inputDir --topLevelSeqSizeFile $workflowDataDir/$topLevelSeqSizeFile --strandSpecific $ss";

  if($undo){
      # can't undo this step.  must undo cluster task
  }else{
      if ($test) {
	  $self->testInputFile('inputDir', "$workflowDataDir/$inputDir");
	  $self->testInputFile('topLevelSeqSizeFile', "$workflowDataDir/$topLevelSeqSizeFile");
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

