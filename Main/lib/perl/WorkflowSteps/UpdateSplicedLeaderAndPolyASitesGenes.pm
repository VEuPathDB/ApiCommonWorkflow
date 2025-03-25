package ApiCommonWorkflow::Main::WorkflowSteps::UpdateSplicedLeaderAndPolyASitesGenes;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $type = $self->getParamValue('type');

  my $sampleName = $self->getParamValue('sampleName');

  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $gusConfigFile = $self->getParamValue('gusConfigFile');
  $gusConfigFile = $self->getWorkflowDataDir() . "/$gusConfigFile";

  my $tuningTablePrefix = $self->getTuningTablePrefix($test, $organismAbbrev, $gusConfigFile);

  my $allowed="'Splice Site' or 'Poly A'";

  my $gusConfigFile= "$ENV{GUS_HOME}/config/gus.config";

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd;

  if($type eq 'Splice Site'){
        $cmd = "updateSpliceSiteGenesBySampleName --gusConfigFile $gusConfigFile --sampleName '$sampleName' --tuningTablePrefix $tuningTablePrefix  --commit";
  }elsif($type eq 'Poly A'){
        $cmd = "updatePolyAGenesBySampleName --gusConfigFile $gusConfigFile --sampleName '$sampleName' --commit";
  }else{
      $self->error("Invalide type '$type'. Allowed types are: $allowed");
  }
  
  if ($undo) {
      #do nothing
  }else {
    $self->runCmd($test, $cmd);
  }

}

1;
