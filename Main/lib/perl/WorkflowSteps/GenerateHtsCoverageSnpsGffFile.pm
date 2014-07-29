package ApiCommonWorkflow::Main::WorkflowSteps::GenerateHtsCoverageSnpsGffFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $configFile = $self->getParamValue('configFile');

  my $outputFile =  $self->getParamValue('outputFile');

  my $referenceOrganism =  $self->getParamValue('referenceOrganism');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "generateHtsCoverageSnps.pl --configFile $workflowDataDir/$configFile --referenceOrganism '$referenceOrganism' --output $workflowDataDir/$outputFile";
  
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
