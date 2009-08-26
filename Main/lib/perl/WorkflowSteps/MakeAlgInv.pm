package ApiCommonWorkflow::Main::WorkflowSteps::MakeAlgInv;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $algName = $self->getParamValue('algName');
  my $algVersion = $self->getParamValue('algVersion');
  my $algDesc = $self->getParamValue('algDesc');
  my $algResult = $self->getParamValue('algResult');

  $algName =~ s/\s//g;
  $algName =~ s/\///g;


  my $args = "--AlgorithmName $algName --AlgorithmDescription $algDesc --AlgImpVersion $algVersion  --AlgInvocStart '2000-01-01' --AlgInvocEnd '2000-01-01' --AlgInvocResult '$algResult'";

  $self->runPlugin($test, $undo,
		   "GUS::Community::Plugin::InsertMinimalAlgorithmInvocation",
		   $args);
}

sub getParamsDeclaration {
  return (
          'algName',
          'algVersion',
          'algDesc',
          'algResult',
         );
}

sub getConfigDeclaration {
  return (
         # [name, default, description]
         # ['', '', ''],
         );
}


