package ApiCommonWorkflow::Main::WorkflowSteps::RunMcl;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $workflowDataDir = $self->getWorkflowDataDir();

  my $inflation = $self->getParamValue('inflation');
  my $inputFile = "$workflowDataDir/" . $self->getParamValue('inputFile');
  my $outputFile = "$workflowDataDir/" . $self->getParamValue('outputFile');
  my $mclPath = $self->getConfig('mclPath');

  my $cmd = "$mclPath $inputFile --abc -I $inflation -o $outputFile ";

  if ($undo) {
    $self->runCmd(0, "rm -f $outputFile");
  } else {
    $self->testInputFile('inputFile', "$inputFile");
    if ($test) {
      $self->runCmd(0,"echo test > $outputFile");
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


1;
