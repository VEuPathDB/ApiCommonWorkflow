package ApiCommonWorkflow::Main::WorkflowSteps::UpdateOntologySynonym;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;

use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $plugin = $self->getParamValue("plugin");
  my $enableUndo = $self->getParamValue("enableUndo");
  my %params;
  
  $params{'extDbRlsSpec'} = $self->getParamValue('webDisplayOntologyName');
  if($params{'extDbRlsSpec'} !~ /.+\|.+/ ){
    $params{'extDbRlsSpec'} = sprintf( "OntologyTerm_%s_RSRC|dontcare",$self->getParamValue('webDisplayOntologyName'));
  }
  $params{extDbRlsSpec} = sprintf("'%s'", $params{extDbRlsSpec});
  
  
  $params{'attributesFile'} = $self->getMetadataPath($self->getParamValue("attributesFile"));
  $params{'append'} = 1;

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


