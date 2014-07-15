package ApiCommonWorkflow::Main::WorkflowSteps::ExtractPolyAGenes;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $configFile = $self->getParamValue('configFile');
  my $outputUniqFile = $self->getParamValue('outputUniqFile');
  my $outputNonUniqFile = $self->getParamValue('outputNonUniqFile');

  my $workflowDataDir = $self->getWorkflowDataDir();


  my $cmd="extractPolyAGenes --uniqFile $workflowDataDir/$outputUniqFile --nonUniqFile $workflowDataDir/$outputNonUniqFile --configFile $workflowDataDir/$configFile";

    if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputUniqFile");
      $self->runCmd(0, "rm -f $workflowDataDir/$outputNonUniqFile");
    } else {
	if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputNonUniqFile");
	    $self->runCmd(0,"echo test > $workflowDataDir/$outputUniqFile");
	}
        $self->runCmd($test,$cmd);

    }
}
  
1;

