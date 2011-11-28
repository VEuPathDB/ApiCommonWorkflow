package ApiCommonWorkflow::Main::WorkflowSteps::MakeCdfFileForAffyArray;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use File::Copy;


sub run {
  my ($self, $test, $undo) = @_;

  my $gene2probesInputFile = $self->getParamValue('gene2probesInputFile');
  my $probename2sequenceInputFile = $self->getParamValue('probename2sequenceInputFile');
  my $inputCdfFile = $self->getParamValue('inputCdfFile');
  my $outputCdfFile = $self->getParamValue('outputCdfFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd1 = "get_pbase-tbase.pl $workflowDataDir/$probename2sequenceInputFile 1 > $workflowDataDir/pbase-tbase.out";

  # overwrites the provided .cdf file
  my $cmd2 = "create_cdf.pl $workflowDataDir/$outputCdfFile $workflowDataDir/$gene2probesInputFile $workflowDataDir/pbase-tbase.out";


  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/pbase-tbase.out");
    $self->runCmd(0, "rm -f $workflowDataDir/$outputCdfFile");
  } else {
    if ($test) {
      $self->testInputFile('gene2probesInputFile', "$workflowDataDir/$gene2probesInputFile");
      $self->testInputFile('probename2sequenceInputFile', "$workflowDataDir/$probename2sequenceInputFile");
      $self->testInputFile('inputCdfFile', "$workflowDataDir/$inputCdfFile");
      $self->runCmd(0,"echo test > $workflowDataDir/pbase-tbase.out");

    }
    copy("$workflowDataDir/$inputCdfFile", "$workflowDataDir/$outputCdfFile") || $self->error("Can't copy inputCdfFile to outputCdfFile $workflowDataDir/$outputCdfFile");

    if (!$test) {
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

