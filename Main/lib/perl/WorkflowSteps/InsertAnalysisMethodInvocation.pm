package ApiCommonWorkflow::Main::WorkflowSteps::InsertAnalysisMethodInvocation;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $name = $self->getParamValue('method');
  my $version = $self->getParamValue('version');
  my $parameters = $self->getParamValue('parameters');

  my $xmlFile = "$ENV{GUS_HOME}/lib/xml/analysisMethods.xml";

  $self->_parseXmlFile($xmlFile);

  if (!$self->{methods}->{$name} || !$self->{methods}->{$name}->{version} eq $version) {
      $self->error("Can't resource '$name' with version '$version' in xml file '$xmlFile'");
  }

  my $args = "--name '$name' --version '$version'  --parameters '$parameters' ";

  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertAnalysisMethod",$args);

}

sub _parseXmlFile {
  my ($self, $methodsXmlFile) = @_;

  my $xml = new XML::Simple();
  $self->{methods} = eval{ $xml->XMLin($methodsXmlFile, SuppressEmpty => undef, KeyAttr => 'method', ForceArray=>['method']) };
#  print STDERR Dumper $self->{data};
  $self->error("Error parsing '$methodsXmlFile': \n$@\n") if($@);
}


sub getParamsDeclaration {
    return (
	'name',
	'version',
	'parameters',
	);
}

sub getConfigDeclaration {
  return (
	 );
}


