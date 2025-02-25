package ApiCommonWorkflow::Main::WorkflowSteps::RunAndMonitorNextflowNGSSamples;

@ISA = (ReFlow::StepClasses::RunAndMonitorNextflow);

use strict;
use ReFlow::StepClasses::RunAndMonitorNextflow;



sub run {
  my ($self, $test, $undo) = @_;

  my $nextflowConfigFile = $self->getParamValue('nextflowConfigFile');

  # if the xml has set this config file.. run the cluster job
  if(defined $nextflowConfigFile) {
      $self->SUPER::run($test, $undo);
  }

  # otherwise nothing to see here
}



1;
