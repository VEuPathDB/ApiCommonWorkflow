package ApiCommonWorkflow::Main::WorkflowSteps::MakeGalaxyFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $orthomclVersion = $self->getParamValue('orthomclVersion');
  my $galaxyDir = $workflowDataDir."/".$self->getParamValue('galaxyDir');
  my $coreGroupsFile = $workflowDataDir."/".$self->getParamValue('coreGroupsFile');
  my $residualGroupsFile = $workflowDataDir."/".$self->getParamValue('residualGroupsFile');
  my $coreSequencesFile = $workflowDataDir."/".$self->getParamValue('coreSequencesFile');
  my $residualSequencesFiles = $workflowDataDir."/".$self->getParamValue('residualSequencesFiles');

  my $galaxyGroupsFile = "$galaxyDir/$orthomclVersion"."Groups.txt";
  my $galaxySequencesFile = "$galaxyDir/$orthomclVersion"."sequences.fasta";

  if ($undo) {
    $self->runCmd(0, "rm -rf $galaxyDir") if -e "$galaxyDir";
  } else {
      if ($test) {
	  $self->runCmd(0, "touch $coreGroupsFile");
	  $self->runCmd(0, "touch $residualGroupsFile");
	  $self->runCmd(0, "touch $coreSequencesFile");
	  $self->runCmd(0, "touch $residualSequencesFiles");
      } else {
	  my $cmd = "mkdir $galaxyDir";
	  $self->runCmd($test, $cmd);
	  $cmd = "cat $coreGroupsFile $residualGroupsFile > $galaxyGroupsFile";
	  $self->runCmd($test, $cmd);
	  $cmd = "cat $coreSequencesFile > $galaxySequencesFile";
	  $self->runCmd($test, $cmd);
	  $cmd = "cat $residualSequencesFiles >> $galaxySequencesFile";
	  $self->runCmd($test, $cmd);
      }
  }
}


