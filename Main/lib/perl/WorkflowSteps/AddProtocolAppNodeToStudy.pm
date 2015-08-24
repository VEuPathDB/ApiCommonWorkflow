package ApiCommonWorkflow::Main::WorkflowSteps::AddProtocolAppNodeToStudy;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $experimentName = $self->getParamValue('experimentName');
  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');
  my $name = $self->getParamValue('name');

    my $args = "--name '$name' --extDbSpec '$extDbRlsSpec' --studyName '$experimentName'";

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::AddProtocolAppNodeToStudy", $args);
}

1;
