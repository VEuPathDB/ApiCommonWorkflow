package ApiCommonWorkflow::Main::WorkflowSteps::RunAndMonitorNextflowNGSSamples;

@ISA = (ReFlow::StepClasses::RunAndMonitorNextflow);

use strict;
use ReFlow::StepClasses::RunAndMonitorNextflow;

sub clusterJobInfoFileName { return "ngs-samples-clusterJobInfo.txt"}
sub logFileName { return "ngs-samples-nextflow.log" }
sub traceFileName { return "ngs-samples-trace.txt" }
sub nextflowStdoutFileName { return "ngs-samples-nextflow.txt" }


sub run {
  my ($self, $test, $undo) = @_;

  my $nextflowConfigFile = $self->getParamValue('nextflowConfigFile');
  my $entry = $self->getParamValue('entry');

  # if the xml has set this config file.. run the cluster job
  if($nextflowConfigFile ne "") {
      $self->SUPER::run($test, $undo);
  }

  # otherwise nothing to see here
}



1;
