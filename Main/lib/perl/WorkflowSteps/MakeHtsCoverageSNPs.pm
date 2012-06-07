package ApiCommonWorkflow::Main::WorkflowSteps::MakeHtsCoverageSNPs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $organismAbbrev = $self->getParamValue('organismAbbrev');
  my $coverageSnpsFile = $self->getParamValue('coverageSnpsFile');

  my $organismInfo = $self->getOrganismInfo($test, $organismAbbrev);
  my $referenceOrganism = $organismInfo->getFullName();
  my $workflowDataDir = $self->getWorkflowDataDir();

 my $cmd = "generateHtsCoverageSnpsFromDB.pl --referenceOrganism '$referenceOrganism' --outputFile $workflowDataDir/$coverageSnpsFile";

    if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$coverageSnpsFile");
    } else {
    if ($test) {
        $self->runCmd(0,"echo test > $workflowDataDir/$coverageSnpsFile");
    }else{
        $self->runCmd($test,$cmd);
    }
    }
}

sub getParamDeclaration {
  return ('organismAbbrev',
          'coverageSnpsFile',
         );
}

sub getConfigDeclaration {
  return (
      # [name, default, description]
     );
}

1;
