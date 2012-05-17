package ApiCommonWorkflow::Main::WorkflowSteps::RunMcl;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $mainInflation = $self->getParamValue('mainInflation');
  my $inputFile = $self->getParamValue('inputFile');
  my $outputFile = $self->getParamValue('outputFile');

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $mclDir = "$workflowDataDir/mcl";

  my $cmd = "mcl $mclDir/$inputFile --abc -I $mclDir/$mainInflation -o $mclDir/$outputFile ";

  if ($undo) {
    $self->runCmd(0, "rm -f $mclDir/$outputFile");
  } else {
      if ($test) {
	  $self->testInputFile('inputFile', "$mclDir/$inputFile");
	  $self->runCmd(0,"echo test > $mclDir/$outputFile");
      }
      $self->runCmd($test,$cmd);
  }
}

# predecessor from Steps.pm:
sub runMcl{
  my ($mgr, $mainInflation) = @_;

  my $signal = "runMcl";

  return if $mgr->startStep("Running the MCL algorithm", $signal);

  my $propertySet = $mgr->{propertySet};

  my $logfile = "$mgr->{myPipelineDir}/logs/$signal.log";

  my $outputFile = "$mgr->{dataDir}/mcl/mcl.out";

  my $abcFile = "$mgr->{dataDir}/mcl/mclInput";

  die " $abcFile file does not exist\n" if (! -e $abcFile);

  my $mclCommand = "mcl $abcFile --abc -I $mainInflation -o $outputFile 2>> $logfile";

  $mgr->runCmd($mclCommand);

  $mgr->endStep($signal);
}
