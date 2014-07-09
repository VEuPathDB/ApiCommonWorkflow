package ApiCommonWorkflow::Main::WorkflowSteps::MakeAndLoadAssemblies;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


## to do
## API $self->runCmdInBackground 

sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $ncbiTaxonId = $self->getParamValue('ncbiTaxonId');
  my $reassemble = $self->getParamValue('reassemble') eq "yes" ? "--reassemble" :"";

  my $cap4Dir = $self->getConfig('cap4Dir');

  my $taxonId = $self->getTaxonIdFromNcbiTaxId($test,$ncbiTaxonId);

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $args = "--clusterfile $workflowDataDir/$inputFile $reassemble --taxon_id $taxonId --cap4Dir $cap4Dir";

  my $workflowStepId = $self->getId();
  
  my $pluginCmd = "ga DoTS::DotsBuild::Plugin::UpdateDotsAssembliesWithCap4 --commit $args --workflowstepid $workflowStepId --comment '$args'";

  my $cmd = "runUpdateAssembliesPlugin --clusterFile $workflowDataDir/$inputFile --pluginCmd \"$pluginCmd\"";

  if ($undo) {
    $self->runPlugin($test,$undo, "DoTS::DotsBuild::Plugin::UpdateDotsAssembliesWithCap4", '');
  }else {

    $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");

    $self->runCmd($test, $cmd);
  }
}


1;


