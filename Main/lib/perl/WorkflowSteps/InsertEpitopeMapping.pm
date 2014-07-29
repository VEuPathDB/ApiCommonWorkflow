package ApiCommonWorkflow::Main::WorkflowSteps::InsertEpitopeMapping;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $epiExtDbName = $self->getParamValue('iedbExtDbName');
  my $seqExtDbSpecs = $self->getParamValue('genomeExtDbRlsSpec');

  my $epiExtDbVersion = $self->getExtDbVersion($test,$epiExtDbName );

  my $workflowDataDir = $self->getWorkflowDataDir();

  $inputFile = "$workflowDataDir/$inputFile";
  if (! -e $inputFile) { 
    $self->log("$inputFile does not exist. Assuming that there were no mapped epitopes.  Exiting.");
    return;
  }

  my $args =" --inputFile $inputFile --extDbRelSpec '$epiExtDbName|$epiExtDbVersion' --seqExtDbRelSpec '$seqExtDbSpecs'";


  $self->testInputFile('inputFile', "$inputFile");


    $self->runPlugin ($test,$undo, "ApiCommonData::Load::Plugin::InsertEpitopeFeature","$args");


}


1;
