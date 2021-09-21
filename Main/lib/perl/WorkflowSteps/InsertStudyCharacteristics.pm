package ApiCommonWorkflow::Main::WorkflowSteps::InsertStudyCharacteristics;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;
  my $args = sprintf("--datasetName %s --file %s --owlFile --schema %s",
    $self->getParamValue('datasetName'),
    $self->getParamValue('file'),
    $self->getParamValue('owlFile'),
    $self->getParamValue('schema'),
  );
  
  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertStudyCharacteristics", $args);

}


1;
