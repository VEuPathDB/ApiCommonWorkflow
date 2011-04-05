package ApiCommonWorkflow::Main::WorkflowSteps::SampleSteps;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

TEMPLATE
sub run {
  my ($self, $test, $undo) = @_;

  # get parameters

  # get global properties
  my $ = $self->getSharedConfig('');

  # get step properties
  my $ = $self->getConfig('');

  if ($test) {
  } else {
  }

  if ($undo){
  }else{
   $self->runPlugin($test, '', $args);
  }


}

sub getParamsDeclaration {
  return (
         );
}

sub getConfigDeclaration {
  return (
         # [name, default, description]
         # ['', '', ''],
         );
}

