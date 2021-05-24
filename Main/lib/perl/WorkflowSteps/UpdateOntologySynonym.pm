package ApiCommonWorkflow::Main::WorkflowSteps::UpdateOntologySynonym;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;

use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

use GUS::Model::SRes::OntologySynonym;

sub run {
  my ($self, $test, $undo) = @_;

  my $plugin = $self->getParamValue("plugin");

  my %params;
  
	$params{'extDbRlsSpec'} = sprintf( "OntologyTerm_%s_RSRC\\|dontcare",$self->getParamValue('webDisplayOntologyName'));
  $params{'attributesFile'} = $self->getMetadataPath($self->getParamValue("attributesFile"));

  my $args = join(" ", map { sprintf("--%s %s", $_, $params{$_}) } keys %params );
  
  if(-e $params{'attributesFile'}){
    $self->runPlugin($test, $undo, $plugin, $args);
  }
  else {
    $self->log("No attributes file, nothing to do ($params{'attributesFile'})")
  }
}

sub getMetadataPath {
  my ($self, @args) = @_;
  return join("/", $self->getWorkflowDataDir(), $self->getParamValue("dataDir"), @args);
}


1;


