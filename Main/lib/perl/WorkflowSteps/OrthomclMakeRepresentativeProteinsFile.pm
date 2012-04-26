package ApiCommonWorkflow::Main::WorkflowSteps::OrthomclMakeRepresentativeProteinsFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use File::Basename;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputGroupsDir = $self->getParamValue('inputGroupsDir');
  my $inputProteinFile = $self->getParamValue('inputProteinFile');
  my $outputRepresentativeProteinsFile = $self->getParamValue('outputRepresentativeProteinsFile');
  my $outputSecondaryProteinsFile = $self->getParamValue('outputSecondaryProteinsFile');

  my $workflowDataDir = $self->getWorkflowDataDir();


  my $cmd = "orthomclFindCentralProteins '$workflowDataDir/$inputGroupsDir' $workflowDataDir/$inputProteinFile $workflowDataDir/$outputRepresentativeProteinsFile $workflowDataDir/$outputSecondaryProteinsFile";

  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outputRepresentativeProteinsFile");
      $self->runCmd(0, "rm -f $workflowDataDir/$outputSecondaryProteinsFile");
  }else {
      if ($test){
	  $self->runCmd(0, "echo test> $workflowDataDir/$outputRepresentativeProteinsFile");
	  $self->runCmd(0, "echo test> $workflowDataDir/$outputSecondaryProteinsFile");
      }else{
	  $self->runCmd($test, $cmd);
      }
  }
}

sub getConfigDeclaration {
  return (
	  # [name, default, description]
	 );
}

