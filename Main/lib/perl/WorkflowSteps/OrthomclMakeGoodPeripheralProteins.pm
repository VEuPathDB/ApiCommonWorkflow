package ApiCommonWorkflow::Main::WorkflowSteps::OrthomclMakeGoodPeripheralProteins;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use File::Basename;


sub run {
  my ($self, $test, $undo) = @_;

  my $fastaDir = $self->getParamValue('fastaDir');
  my $fastaFile = $self->getParamValue('fastaFile');
  my $goodFastaFile = $self->getParamValue('goodFastaFile');
  my $poorFastaFile = $self->getParamValue('poorFastaFile');
  my $minLength = $self->getParamValue('minLength');
  my $maxStopPercent = $self->getParamValue('maxStopPercent');
  my $abbrev = $self->getParamValue('abbrev');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "orthomclFilterPeripheralFasta '$workflowDataDir/$fastaDir' $fastaFile $goodFastaFile $poorFastaFile $minLength $maxStopPercent $abbrev";

  $self->testInputFile('fastaFile', "$workflowDataDir/$fastaDir/$fastaFile");

  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$fastaDir/$goodFastaFile");
      $self->runCmd(0, "rm -f $workflowDataDir/$fastaDir/$poorFastaFile");
  }else {
    if ($test){
      $self->runCmd(0, "echo test> $workflowDataDir/$fastaDir/$goodFastaFile");
      $self->runCmd(0, "echo test> $workflowDataDir/$fastaDir/$poorFastaFile");
    }
    $self->runCmd($test, $cmd);
  }

}

1;
