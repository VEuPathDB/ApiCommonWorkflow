package ApiCommonWorkflow::Main::WorkflowSteps::UpdateAssemblySourceId;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {

  my ($self, $test,$undo) = @_;

  my $ncbiTaxonId = $self->getParamValue('ncbiTaxonId');
  my $organismTwoLetterAbbrev = $self->getParamValue('organismTwoLetterAbbrev');

  my $taxonId = $self->getTaxonIdFromNcbiTaxId($test, $ncbiTaxonId);

  my $cmd = "updateAssSourceIdFromPK --prefix '${organismTwoLetterAbbrev}DT.' --suffix '.tmp' --TaxonId $taxonId";

  if ($undo){
  }else{
      $self->runCmd($test, $cmd);      
  }
}

1;


