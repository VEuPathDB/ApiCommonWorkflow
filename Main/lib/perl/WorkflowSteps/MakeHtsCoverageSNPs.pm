package ApiCommonWorkflow::Main::WorkflowSteps::MakeHtsCoverageSNPs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $coverageSnpsFile = $self->getParamValue('coverageSnpsFile');
  my $varscanConsDir = $self->getParamValue('varscanConsDir');

  my $organismInfo = $self->getOrganismInfo($test, $organismAbbrev);
  my $referenceOrganism = $organismInfo->getFullName();
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "generateHtsCoverageSnpsWithQuality.pl --referenceOrganism '$referenceOrganism' --varscanDir $workflowDataDir/$varscanConsDir --outputFile $workflowDataDir/$coverageSnpsFile";
  
  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$coverageSnpsFile");
  } else {
    if ($test) {
      $self->runCmd(0,"echo test > $workflowDataDir/$coverageSnpsFile");
    }
    $self->runCmd($test,$cmd);

  }
}


1;
