package ApiCommonWorkflow::Main::WorkflowSteps::MakeReadsAndQualFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $readFilePath = $self->getParamValue('readFilePath');
  my $hasPairedEnds = $self->getBooleanParamValue('hasPairedEnds');
  my $outputReadsFile = $self->getParamValue('outputReadsFile');
  my $outputQualFile = $self->getParamValue('outputQualFile');

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $qualCmd="fastq2qualities.pl $workflowDataDir/$readFilePath".($hasPairedEnds ? " $workflowDataDir/$readFilePath.paired" : "").">$workflowDataDir/$outputQualFile";
  my $readCmd="parse2fasta.pl $workflowDataDir/$readFilePath".($hasPairedEnds ? " $workflowDataDir/$readFilePath.paired" : "").">$workflowDataDir/$outputReadsFile";
  
  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputReadsFile");
      $self->runCmd(0, "rm -f $workflowDataDir/$outputQualFile");
  } else {
      if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputQualFile");
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputReadsFile");
      }
      $self->runCmd($test, $qualCmd);
      $self->runCmd($test, $readCmd);
  }
}

1;


