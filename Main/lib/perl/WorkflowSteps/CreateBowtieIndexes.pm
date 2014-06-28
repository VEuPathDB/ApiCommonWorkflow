package ApiCommonWorkflow::Main::WorkflowSteps::CreateBowtieIndexes;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');

  my $outputIndexDir = $self->getParamValue('outputIndexDir');

  my $colorspace = $self->getBooleanParamValue('colorspace');

  my $bowtieVersion = $self->getParamValue('bowtieVersion');

  my $workflowDataDir = $self->getWorkflowDataDir();

  
  $self->error("Colorspace only valid for bowtie version 1") if($colorspace && $bowtieVersion != 1);

  $self->runCmd(0,"mkdir -p $workflowDataDir/$outputIndexDir");

  my $cmd= "createBowtieIndexes --inputFile $workflowDataDir/$inputFile --outputIndexDir $workflowDataDir/$outputIndexDir/genomicIndexes --bowtieVersion $bowtieVersion";

  if($colorspace) {
    $cmd .= " --colorspace" ;
  }

  if($undo){
      $self->runCmd(0,"rm -fr $workflowDataDir/$outputIndexDir");
  }else{
    $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
    $self->runCmd($test, $cmd);
  }
}

1;
