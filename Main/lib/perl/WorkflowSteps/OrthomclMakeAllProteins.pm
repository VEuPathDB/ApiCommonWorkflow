package ApiCommonWorkflow::Main::WorkflowSteps::OrthomclMakeAllProteins;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $outputFile = $self->getParamValue('outputFile');

  my $maxStopPercent = $self->getParamValue('maxStopPercent');

  my $minLength = $self->getParamValue('minLength');

  my $sql = "SELECT source_id,sequence
               FROM dots.AASequence";

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "gusExtractSequences --outputFile $workflowDataDir/$outputFile --idSQL \"$sql\" --maxStopCodonPercent $maxStopPercent --minLength $minLength --verbose";

  my $cmd2 = "sed -i 's/*/X/g' $workflowDataDir/$outputFile";

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {  
      if ($test) {
	  $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
      }
      $self->runCmd($test,$cmd);
      $self->runCmd($test,$cmd2);
  }
}

1;
