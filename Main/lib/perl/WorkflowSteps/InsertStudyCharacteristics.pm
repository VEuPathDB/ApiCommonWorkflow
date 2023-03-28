package ApiCommonWorkflow::Main::WorkflowSteps::InsertStudyCharacteristics;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


my $schema = "EDA"; # always in this context

sub run {
  my ($self, $test, $undo) = @_;

  my $args = sprintf("--datasetName %s --file %s --owlFile %s --schema %s",
    $self->getParamValue('datasetName'),
    $ENV{GUS_HOME} . "/" . $self->getParamValue('file'),
    $ENV{GUS_HOME} . "/" . $self->getParamValue('owlFile'),
    $schema
  );
  
  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertStudyCharacteristics", $args);

}


1;
