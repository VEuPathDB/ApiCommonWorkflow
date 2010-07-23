package ApiCommonWorkflow::Main::WorkflowSteps::InsertOrganismProject;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $organism = $self->getParamValue('organism');
  my $project = $self->getParamValue('project');

  my $args = "--organism $organism --projectName $project";

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertOrganismProjectFeature", $args);

}

sub getParamDeclaration {
  return (
	  'organism',
	  'project',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

