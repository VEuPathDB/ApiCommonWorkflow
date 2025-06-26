package ApiCommonWorkflow::Main::WorkflowSteps::ExtractSplicedLeaderAndPolyASitesGenes;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;


  my $gusConfigFile = $self->getWorkflowDataDir() . "/" . $self->getParamValue('gusConfigFile');
  my $analysisConfigFile = $self->getParamValue('analysisConfigFile');
  my $workingDir = $self->getParamValue('workingDir');
  my $extDbRlsSpec = $self->getParamValue('extDbRlsSpec');
  my $ties = $self->getParamValue('pctTies');
  my $type = $self->getParamValue('type');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "extractSpliceSiteAndPolyAGenes.pl --gusConfigFile $gusConfigFile --analysisConfigFile $workflowDataDir/$analysisConfigFile --workingDir $workflowDataDir/$workingDir --type '$type' --extDbRlsSpec '$extDbRlsSpec' --ties $ties";

    if ($undo) {
      # undo here doesn't need to do anything
    } else {
        $self->runCmd($test,$cmd);
    }
}
  
1;
