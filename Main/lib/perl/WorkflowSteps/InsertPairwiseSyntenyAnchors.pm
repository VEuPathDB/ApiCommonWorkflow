package ApiCommonWorkflow::Main::WorkflowSteps::InsertPairwiseSyntenyAnchors;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  my $maxForks = 6;

# the directory that has mercator output.  this is our input
  my $mercatorOutputsDir = $self->getParamValue('mercatorOutputsDir');
  my $workflowDataDir = $self->getWorkflowDataDir();
  my $mercatorPairsDir = join("/", $workflowDataDir,$mercatorOutputsDir);
  my $nextflowDataDir = join("/", $workflowDataDir, "insertPairwiseSyntenyAnchors");
  my $stepDir = $self->getStepDir();
  mkdir ($nextflowDataDir) unless ( -d $nextflowDataDir );

# in test mode, there are no input files to iterate over, so just leave
  if ($test) {
    $self->testInputFile('mercatorOutputsDir', "$mercatorPairsDir");
    return;
  }

  if($undo){
    $self->runCmd($test,"rm -rf $nextflowDataDir") if( -d $nextflowDataDir );
    $self->runCmd($test,"rm -rf $stepDir/.nextflow") if( -d "$stepDir/.nextflow" );
    return;
  }

#TODO
  # Consider moving the config file to Datasets, or encoding maxForksin Datasets, or something else
  # For now we assume the config file doesn't exist
  my $nfConfigFile= join("/", $nextflowDataDir, 'Mercator_Nextflow.config');
  unless (-e $nfConfigFile){
    my $nfConfig = <<CONFIG;
params {
  mercatorPairsDir = "$mercatorPairsDir"
}
process {
  executor = 'local'
  withName: 'processPairs' { maxForks = $maxForks }
}
CONFIG
    open(FH, ">$nfConfigFile") or die "Cannot write config file $nfConfigFile: $!\n";
    print FH $nfConfig;
    close(FH);
  }

  my $executable = join("/", $ENV{'GUS_HOME'}, 'bin', 'processSyntenyPairs');
  my $logFile = join("/", $stepDir, "step.err");

  my $cmd = "export NXF_WORK=$nextflowDataDir/work && nextflow -bg -C $nfConfigFile -log $logFile run $executable";

## If you are here to look at an example of nextflow usage:
# -bg run in background option: nextflow will not run if you run your workflow (rf run real) in a background shell
# -log : override the default (.nextflow.log)
# NXF_WORK will contain logs for individual jobs (building and loading sqlldr files)

  $self->log("Running: $cmd\n");
  $self->runCmd($test,$cmd);
}

1;
