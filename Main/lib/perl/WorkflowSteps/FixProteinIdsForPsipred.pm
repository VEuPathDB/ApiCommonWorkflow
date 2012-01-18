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

  my $cmd = "shortenFastaSeqs --finalLength 9999 --inputFile $workflowDataDir/$inputProteinsFile --outputFile $workflowDataDir/${inputProteinsFile}_temp";

  my $cmd2 = "cat $workflowDataDir/${inputProteinsFile}_temp | perl -pe '$fix' > $workflowDataDir/$outputProteinsFile";

  my $cmd3 = "rm -f $workflowDataDir/${inputProteinsFile}_temp";


  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputProteinsFile");
    $self->runCmd(0, "rm -f $workflowDataDir/$outputProteinsFile.d*");
    $self->runCmd(0, "rm -f $workflowDataDir/$outputProteinsFile.pag");
  } else {
      if ($test){
	  $self->testInputFile('inputProteinsFile', "$workflowDataDir/$inputProteinsFile");
	  $self->runCmd(0,"echo test > $workflowDataDir/$outputProteinsFile");
      }else{
	  $self->runCmd($test,$cmd);
          $self->runCmd($test,$cmd2);
          $self->runCmd($test,$cmd3);
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


