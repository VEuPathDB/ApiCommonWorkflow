package ApiCommonWorkflow::Main::WorkflowSteps::RunRum2Sam;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $uniqueFile = $self->getParamValue('uniqueFile');

  my $nuFile = $self->getParamValue('nuFile');

  my $fastaFile = $self->getParamValue('fastaFile');

  my $qualFile = $self->getParamValue('qualFile');

  my $samFile = $self->getParamValue('samFile');

  my $samHeaderFile = $self->getParamValue('samHeaderFile');

  my $workflowDataDir = $self->getWorkflowDataDir();


    if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$samFile");
  } else {
      if ($test) {
	  $self->testInputFile('seqFile', "$workflowDataDir/$uniqueFile");
          $self->testInputFile('seqFile', "$workflowDataDir/$nuFile");
          $self->testInputFile('seqFile', "$workflowDataDir/$fastaFile");
          $self->testInputFile('seqFile', "$workflowDataDir/$qualFile");
	  $self->runCmd(0, "echo test > $workflowDataDir/$samFile");
      }else{
          my $cmd = "rum2sam.pl $workflowDataDir/$uniqueFile $workflowDataDir/$nuFile $workflowDataDir/$fastaFile $workflowDataDir/$qualFile $workflowDataDir/$samFile.noHeader";
	  $self->runCmd($test,$cmd);
	  $cmd = "cat $workflowDataDir/$samHeaderFile $workflowDataDir/$samFile.noHeader > $workflowDataDir/$samFile";
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

