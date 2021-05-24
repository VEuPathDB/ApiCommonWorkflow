package ApiCommonWorkflow::Main::WorkflowSteps::InsertPARFeatures;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $mappingFile = $self->getParamValue('mappingFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--mappingFile '$workflowDataDir/$mappingFile'";

  #$self->testInputFile('mappingFile', "$workflowDataDir/$mappingFile");

  if (-e "$workflowDataDir/$mappingFile"){
    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertPARFeatures", $args);
  }else{
   $self->log("No mappingFile Exists!\n") 
  }
}

1;
