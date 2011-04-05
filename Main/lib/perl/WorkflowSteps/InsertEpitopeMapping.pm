package ApiCommonWorkflow::Main::WorkflowSteps::InsertEpitopeMapping;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $epiExtDbSpecs = $self->getParamValue('iedbExtDbRlsSpec');
  my $seqExtDbSpecs = $self->getParamValue('genomeExtDbRlsSpec');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args =" --inputFile $workflowDataDir/$inputFile --extDbRelSpec '$epiExtDbSpecs' --seqExtDbRelSpec '$seqExtDbSpecs'";

    if ($test) {
      $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
    }

    $self->runPlugin ($test,$undo, "ApiCommonData::Load::Plugin::InsertEpitopeFeature","$args");


}


sub getParamsDeclaration {
  return ('inputFile',
	  'iedbExtDbRlsSpec',
	  'genomeExtDbRlsSpec'
	 );
}


sub getConfigDeclaration {
  return (
	  # [name, default, description]
 	 );
}



