package ApiCommonWorkflow::Main::WorkflowSteps::RegisterPlugins;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $gusConfigFile = "--gusConfigfile " . $self->getGusConfigFile();

  my $cmd = "registerAllPlugins.pl $gusConfigFile";

  $self->runCmd($test, $cmd);
}


1;
