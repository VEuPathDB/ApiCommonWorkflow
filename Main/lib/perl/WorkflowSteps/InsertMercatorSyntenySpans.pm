package ApiCommonWorkflow::Main::WorkflowSteps::InsertMercatorSyntenySpans;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test) = @_;

  # get parameters
  my $inputDir = $self->getParamValue('inputDir');
  my $genomeVirtualSeqsExtDbRlsSpec = $self->getParamValue('genomeVirtualSeqsExtDbRlsSpec');
  my $genomeExtDbRlsSpec = $self->getParamValue('genomeExtDbRlsSpec');

  # get global properties
  my $ = $self->getSharedConfig('');

  # get step properties
  my $ = $self->getConfig('');

  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($test) {
  } else {
  }

  $self->runPlugin($test, '', $args);

}

sub getParamsDeclaration {
  return (
          'inputDir',
          'genomeVirtualSeqsExtDbRlsSpec',
          'genomeExtDbRlsSpec',
         );
}

sub getConfigDeclaration {
  return (
         # [name, default, description]
         # ['', '', ''],
         );
}

sub restart {
}

sub undo {

}

sub getDocumentation {
}
