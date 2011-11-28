package ApiCommonWorkflow::Main::WorkflowSteps::FixProteinIdsForPsipred;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $inputProteinsFile = $self->getParamValue('inputProteinsFile');
  my $outputProteinsFile = $self->getParamValue('outputProteinsFile');

  #want to replace all '-' with _DASH_ in protein id
  my $fix = 's/-/_DASH_/g';

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "cat $workflowDataDir/$inputProteinsFile | perl -pe '$fix' > $workflowDataDir/$outputProteinsFile";

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputProteinsFile");
  } else {
      if ($test){
	  $self->testInputFile('inputProteinsFile', "$workflowDataDir/$inputProteinsFile");
	  $self->runCmd(0,"echo test > $workflowDataDir/$outputProteinsFile");
      }else{
	  $self->runCmd($test,$cmd);
      }
  }
}


sub getParamsDeclaration {
  return ('inputProteinsFile',
	  'outputProteinsFile'
	 );
}


sub getConfigDeclaration {
  return (
	  # [name, default, description]
 	 );
}


