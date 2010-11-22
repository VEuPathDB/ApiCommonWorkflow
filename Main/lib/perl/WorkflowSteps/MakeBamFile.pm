package ApiCommonWorkflow::Main::WorkflowSteps::MakeBamFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $samFile = $self->getParamValue('samFile');

  my $bamFile = $self->getParamValue('bamFile');

  my $bamIndex = $self->getParamValue('bamIndex');

  my $workflowDataDir = $self->getWorkflowDataDir();


    if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$bamFile");

    $self->runCmd(0, "rm -f $workflowDataDir/$bamIndex");
  } else {
      if ($test) {
	  $self->testInputFile('seqFile', "$workflowDataDir/$samFile");
      }else{
          my $cmd = "samtools view $workflowDataDir/$samFile > $workflowDataDir/$bamFile";
	  $self->runCmd($test,$cmd);
	  my $cmd = "samtools index $workflowDataDir/$bamFile $workflowDataDir/$bamIndex";
	  $self->runCmd($test,$cmd);
      }
  }
}


sub getParamDeclaration {
  my @properties = 
    (
     ['uniqueFile'],
     ['nuFile'],
     ['fastaFile'],
     ['qualFile'],
     ['samFile'],
    );
  return @properties;
}

sub getDocumentation {
}


sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

