package ApiCommonWorkflow::Main::WorkflowSteps::MakeReadsAndQualFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $readFilePath = $self->getParamValue('readFilePath');
  my $hasPairedEnds = $self->getParamValue('hasPairedEnds');
  my $outputReadsFile = $self->getParamValue('outputReadsFile');
  my $outputQualFile = $self->getParamValue('outputQualFile');

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $qualCmd="fastq2qualities.pl $workflowDataDir/$readFilePath".($hasPairedEnds ? " $workflowDataDir/$readFilePath.paired" : "");
  my $readCmd="parse2fasta.pl $workflowDataDir/$readFilePath".($hasPairedEnds ? " $workflowDataDir/$readFilePath.paired" : "");
  
  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputReadsFile");
      $self->runCmd(0, "rm -f $workflowDataDir/$outputQualFile");
  } else {
      if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputQualFile");
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputReadsFile");
      }else{
	  $self->runCmd($test, $qualCmd);
	  $self->runCmd($test, $readCmd);
      }
  }
}

sub getParamsDeclaration {
  return (
	  'readFilePath',
	  'hasPairedEnds',
	  'outputReadsFile',
	  'outputQualFile',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}


