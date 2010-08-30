package ApiCommonWorkflow::Main::WorkflowSteps::MakeCdfFileForAffyArray;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $gene2probesInputFile = $self->getParamValue('gene2probesInputFile');
  my $probename2sequenceInputFile = $self->getParamValue('probename2sequenceInputFile');
  my $cdfFile = $self->getParamValue('cdfFile');
  my $tbasePbaseFile = $self->getParamValue('tbasePbaseFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd1 = "get_pbase-tbase.pl $workflowDataDir/$probename2sequenceInputFile 1 > $workflowDataDir/$tbasePbaseFile"

  my $cmd2 = "create_cdf.pl $workflowDataDir/$cdfFile $workflowDataDir/$gene2probesInputFile $workflowDataDir/$tbasePbaseFile"



  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/tbase-pbase.out");
  } else {
      if ($test) {
	  $self->testInputFile('gene2probesInputFile', "$workflowDataDir/$gene2probesInputFile");
	  $self->testInputFile('probename2sequenceInputFile', "$workflowDataDir/$probename2sequenceInputFile");
	  $self->testInputFile('gene2probesInputFile', "$workflowDataDir/$gene2probesInputFile");
      }else{
	  $self->runCmd($test,$cmd1);
	  $self->runCmd($test,$cmd2);
      }
  }
}

sub getParamDeclaration {
  return (
	  'gene2probesInputFile',
	  'probename2sequenceInputFile',
	  'gene2probesInputFile',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

