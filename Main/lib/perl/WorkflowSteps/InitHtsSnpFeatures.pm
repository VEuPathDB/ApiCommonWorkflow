package ApiCommonWorkflow::Main::WorkflowSteps::InitHtsSnpFeatures;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $organismAbbrev = $self->getParamValue('organismAbbrev');

  my $organismInfo = $self->getOrganismInfo($test, $organismAbbrev);
  my $referenceOrganism = $organismInfo->getFullName();

  my $cmd = "echo 'initHtsSnpFeatures for $referenceOrganism complete'";
  my $undoCmd = "undoInitHtsSnpFeatures.pl --referenceOrganism '$referenceOrganism' ";

  if ($undo) {
    $self->runCmd(0, $undoCmd);
  } else {
    if ($test) {
      $self->runCmd(0,"echo test; $cmd");
    }else{
      $self->runCmd($test,$cmd);
    }
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
