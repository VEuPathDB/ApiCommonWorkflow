package ApiCommonWorkflow::Main::WorkflowSteps::RunParse2fasta;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $shortSeqsFile = $self->getParamValue('shortSeqsFile');

  my $pairedEndFile = $self->getParamValue('pairedEndFile');

  my $outputFile = $self->getParamValue('outputFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  $outputFile = $pairedEndFile ? $outputFile : $shortSeqsFile;

    if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
    $self->runCmd(0, "mv $workflowDataDir/$shortSeqsFile.org $workflowDataDir/$shortSeqsFile") unless $pairedEndFile;
  } else {
      if ($test) {
	  $self->testInputFile('seqFile', "$workflowDataDir/$shortSeqsFile");
	  $self->runCmd(0,"echo test > $workflowDataDir/$shortSeqsFile.org");
          $self->testInputFile('seqFile', "$workflowDataDir/$pairedEndFile") if $pairedEndFile;
      }else{
	  $self->runCmd($test,"mv $workflowDataDir/$shortSeqsFile $workflowDataDir/$shortSeqsFile.org");
          my $cmd = "parse2fasta.pl $workflowDataDir/$shortSeqsFile.org";
	  $cmd .= " $workflowDataDir/$pairedEndFile" if $pairedEndFile;
	  $cmd .= " > $workflowDataDir/$outputFile";
	  $self->runCmd($test,$cmd);
      }
  }
}


sub getParamDeclaration {
  my @properties = 
    (
     ['shortSeqsFile'],
     ['pairedEndFile'],
     ['outputFile'],
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

