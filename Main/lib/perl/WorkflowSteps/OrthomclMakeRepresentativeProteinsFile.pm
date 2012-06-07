package ApiCommonWorkflow::Main::WorkflowSteps::OrthomclMakeRepresentativeProteinsFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use File::Basename;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputGroupsDir = $self->getParamValue('inputGroupsDir');
  my $inputProteinFile = $self->getParamValue('inputProteinsFile');
  my $outputRepresentativeProteinsFile = $self->getParamValue('outputRepresentativeProteinsFile');
#  my $outputSecondaryProteinsFile = $self->getParamValue('outputSecondaryProteinsFile');
  my $outputGroupsFile = $self->getParamValue('outputGroupsFile');
  my $proteinIdPrefix = $self->getParamValue('proteinIdPrefix');

  my $workflowDataDir = $self->getWorkflowDataDir();


  my $cmd = "orthomclFindRepresentativeProteins '$workflowDataDir/$inputGroupsDir' $workflowDataDir/$inputProteinFile $workflowDataDir/$outputRepresentativeProteinsFile $workflowDataDir/$outputGroupsFile $proteinIdPrefix";

  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputRepresentativeProteinsFile");
#      $self->runCmd(0, "rm -f $workflowDataDir/$outputSecondaryProteinsFile");
      $self->runCmd(0, "rm -f $workflowDataDir/$outputGroupsFile");
  }else {
      if ($test){
	  $self->runCmd(0, "echo test> $workflowDataDir/$outputRepresentativeProteinsFile");
#	  $self->runCmd(0, "echo test> $workflowDataDir/$outputSecondaryProteinsFile");
	  $self->runCmd(0, "echo test> $workflowDataDir/$outputGroupsFile");
      }
      $self->runCmd($test, $cmd);
  }
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

