package ApiCommonWorkflow::Main::WorkflowSteps::MakeSortedBAMFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');

  my $outputFile =  $self->getParamValue('outputFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "samtools view -uS $workflowDataDir/$inputFile > $workflowDataDir/$outputFile";
  
  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  }else {
    if ($test){
        $self->runCmd(0, "echo test > $workflowDataDir/$outputFile");
    }
    $self->runCmd($test, $cmd);

  }

}

1;
