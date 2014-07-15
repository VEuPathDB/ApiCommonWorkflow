package ApiCommonWorkflow::Main::WorkflowSteps::RunMDust;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self,$test, $undo) = @_;


    my $inputSeqsFile = $self->getParamValue('inputSeqsFile');
    my $outputSeqsFile = $self->getParamValue('outputSeqsFile');

    my $workflowDataDir = $self->getWorkflowDataDir();
    my $mdustPath = $self->getConfig('mdustPath');


    if ($undo) {
	$self->runCmd(0, "rm -f $workflowDataDir/$outputSeqsFile");
    }else{
      $self->testInputFile('inputSeqsFile', "$workflowDataDir/$inputSeqsFile");
      if ($test) {
        $self->runCmd(0,"echo test > $workflowDataDir/$outputSeqsFile");
      }
      $self->runCmd($test,"mdust $workflowDataDir/$inputSeqsFile > $workflowDataDir/$outputSeqsFile");
    }
}

1;
