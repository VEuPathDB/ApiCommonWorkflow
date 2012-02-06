package ApiCommonWorkflow::Main::WorkflowSteps::InsertAnalysisMethodInvocation;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $name = $self->getParamValue('method');
  my $version = $self->getParamValue('version');
  my $parameters = $self->getParamValue('parameters');

  my $args = "--name '$name' --version '$version'  --parameters '$parameters' ";

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertAnalysisMethodInvocation",$args);

}

sub getConfigDeclaration {
  return (
	 );
}


