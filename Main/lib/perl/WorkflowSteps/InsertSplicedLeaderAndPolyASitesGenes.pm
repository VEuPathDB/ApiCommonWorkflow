package ApiCommonWorkflow::Main::WorkflowSteps::InsertSplicedLeaderAndPolyASitesGenes;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $type = $self->getParamValue('type');

  my $sampleName = $self->getParamValue('sampleName');

  my $allowed="'Splice Site' or 'Poly A'";

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--sampleName $sampleName";

  if($type eq 'Splice Site'){
      $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertSpliceSiteGenes", $args);
  }elsif($type eq 'Poly A'){
      $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertPolyAGenes", $args);
  }else{
      $self->error("Invalide type '$type'. Allowed types are: $allowed");
  }
}

sub getParamDeclaration {
  return (
	  'sampleName',
	 );
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

