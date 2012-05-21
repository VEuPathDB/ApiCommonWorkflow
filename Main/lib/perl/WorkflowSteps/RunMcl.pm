package ApiCommonWorkflow::Main::WorkflowSteps::RunMcl;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inflation = $self->getParamValue('inflation');
  my $inputFile = $self->getParamValue('inputFile');
  my $outputFile = $self->getParamValue('outputFile');

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $cmd = "mcl $workflowDataDir/$inputFile --abc -I $inflation -o $workflowDataDir/$outputFile ";

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$outputFile");
  } else {
      if ($test) {
	  $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
	  $self->runCmd(0,"echo test > $workflowDataDir/$outputFile");
      }
      $self->runCmd($test,$cmd);
  }
}

=head1

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

=cut
