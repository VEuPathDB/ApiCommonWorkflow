package ApiCommonWorkflow::Main::WorkflowSteps::InsertCustomOntolgyEntries;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $file = $self->getParamValue("file");

  my $args = "--name '$file'";

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertCustomOntologyEntries", $args);

}

1;
