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
  mkdir ($nextflowDataDir) unless ( -d $nextflowDataDir );

# in test mode, there are no input files to iterate over, so just leave
  if ($test) {
    $self->testInputFile('mercatorOutputsDir', "$mercatorPairsDir");
    return;
  }

  if($undo){
    $self->runCmd($test,"rm -rf $nextflowDataDir") if( -d $nextflowDataDir );
  }

#TODO
  # Consider moving the config file to Datasets, or encoding maxForksin Datasets, or something else
  # For now we assume the config file doesn't exist
  my $nfConfigFile= join("/", $workflowDataDir, 'Mercator_Nextflow.config');
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

  my $cmd = "nextflow -C $nfConfigFile run processSyntenyPairs";
  $self->log("Running: $cmd\n");
  $self->runCmd($test,$cmd);
}

1;
