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

  my $cmd = "orthomclFilterPeripheralFasta $fastaDir $fastaFile $goodFastaFile $poorFastaFile $minLength $maxStopPercent";

  $self->testInputFile('fastaFile', "$fastaDir/$fastaFile");

  if ($undo) {
      $self->runCmd(0, "rm -f $fastaDir/$goodFastaFile");
      $self->runCmd(0, "rm -f $fastaDir/$poorFastaFile");
  }else {
    if ($test){
      $self->runCmd(0, "echo test> $fastaDir/$goodFastaFile");
      $self->runCmd(0, "echo test> $fastaDir/$poorFastaFile");
    }
    $self->runCmd($test, $cmd);
  }

}

1;
