package ApiCommonWorkflow::Main::WorkflowSteps::InsertMassSpecPeptides;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');

 # my $version = $self->getConfig('version');

  my ($extDbName,$extDbRlsVer) = $self->getExtDbInfo($test,$extDbRlsSpec);

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--gff_file $workflowDataDir/$inputFile --extDbRlsSpec '$extDbRlsSpec'";


  $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertMassSpecPeptides", $args);
}

1;

