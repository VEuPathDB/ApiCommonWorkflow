package ApiCommonWorkflow::Main::WorkflowSteps::CreateBWAIndexes
;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');

  my $outputIndexDir = $self->getParamValue('outputIndexDir');

  my $bwaPath = $self->getConfig('bwaPath');

  my $workflowDataDir = $self->getWorkflowDataDir();

  $self->runCmd(0,"mkdir -p $workflowDataDir/$outputIndexDir");

  my $cmd= "$bwaPath/bwa index -p $workflowDataDir/$outputIndexDir/genomicIndexes $workflowDataDir/$inputFile";

  if($undo){

      $self->runCmd(0,"rm -fr $workflowDataDir/$outputIndexDir");

  }else{
    $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
    $self->runCmd($test, $cmd);
  }
}

1;
