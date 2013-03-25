package ApiCommonWorkflow::Main::WorkflowSteps::UpdateHtsSnpFeatures;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $organismAbbrev = $self->getParamValue('organismAbbrev');

  my $organismInfo = $self->getOrganismInfo($test, $organismAbbrev);
  my $referenceOrganism = $organismInfo->getFullName();
  unless($referenceOrganism) {
    $self->error("Organism Abbreviation for the reference [$organismAbbrev] was not defined");   
  }

  my $args = "--organism $referenceOrganism";
  
  if ($undo) {
    $self->runCmd(0,"echo undoing updating SNPs for $referenceOrganism ... nothing to be done");
  } elsif ($test) {
      $self->runCmd(0,"echo testing coverage SNPs for $referenceOrganism");
  }else{
    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::UpdateHtsSnpsFromSeqVars", $args);
  }
}

sub getParamDeclaration {
  return ('organismAbbrev',
         );
}

sub getConfigDeclaration {
  return (
      # [name, default, description]
     );
}

1;
