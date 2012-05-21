package ApiCommonWorkflow::Main::WorkflowSteps::MakeOrthoPairsFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $suffix = $self->getParamValue('suffix');
  my $orthmclGroupsDir = $self->getParamValue('outputGroupsDir');

  my $workflowDataDir = $self->getWorkflowDataDir();
  my $configFile = "$workflowDataDir/orthomclPairs.config";
  my $outDir = "$workflowDataDir/$orthmclGroupsDir";
  chdir $outDir;

  my $cmd = "orthomclDumpPairsFiles $configFile $suffix";

  if ($undo) {
    $self->runCmd($test, "rm -rf pairs");
  } else {
      if ($test) {
	  $self->testInputFile('configFile', "$configFile");
	  $self->runCmd(0, "echo test > $outDir/mclInput");
      }
      $self->runCmd($test, $cmd);
  }
}

=head1

# predecessor from Steps.pm:
sub makeOrthoPairsFiles {
  my ($mgr) = @_;

   my $signal = "orthoPairsFiles";

  return if $mgr->startStep("Dumping orthomcl pairs file", $signal);

  my $mclPath = "$mgr->{dataDir}/mcl/";

  $mgr->runCmd("mkdir -p $mclPath");

  die "$mclPath directory not created\n" if (! -d $mclPath);

  my $logfile = "$mgr->{myPipelineDir}/logs/$signal.log";

  my $propertySet = $mgr->{propertySet};

  my $config = $propertySet->getProp('orthoMclPairsConfig');

  my $cmd = "orthomclDumpPairsFiles $config  2>> $logfile";

  chdir "$mclPath" || die "Can't chdir to $mclPath\n";

  $mgr->runCmd($cmd);

  $mgr->endStep($signal);
}

=cut
