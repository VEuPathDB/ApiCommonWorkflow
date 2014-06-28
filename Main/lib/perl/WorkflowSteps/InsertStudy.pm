package ApiCommonWorkflow::Main::WorkflowSteps::InsertStudy;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $experimentName = $self->getParamValue("experimentName");
  my $experimentExtDbRlsSpec = $self->getParamValue('experimentExtDbRlsSpec');

  my $args = "--name '$experimentName' --extDbRlsSpec '$experimentExtDbRlsSpec'";


  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertStudy", $args);

}


1;
