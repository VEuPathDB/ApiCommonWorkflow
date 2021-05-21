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
    my $errMsg = <<ERRMSG;
NOTICE: this UNDO does not clean up the database! if you wish to clean up, run this SQL to delete ALL synteny datasets:

==================
DELETE FROM apidb.SYNTENICGENE;
DELETE FROM apidb.SYNTENY;
DELETE FROM sres.EXTERNALDATABASERELEASE WHERE EXTERNAL_DATABASE_ID IN (SELECT EXTERNAL_DATABASE_ID FROM sres.EXTERNALDATABASE WHERE name LIKE '%Mercator_synteny');
DELETE FROM sres.EXTERNALDATABASE WHERE name LIKE '%Mercator_synteny';
SG;
==================

OR to delete one pair:
==================
DELETE FROM apidb.SYNTENICGENE WHERE SYNTENY_ID IN (
  SELECT SYNTENY_ID FROM apidb.SYNTENY WHERE EXTERNAL_DATABASE_RELEASE_ID=(
    SELECT EXTERNAL_DATABASE_RELEASE_ID FROM sres.EXTERNALDATABASERELEASE WHERE EXTERNAL_DATABASE_ID=(
      SELECT EXTERNAL_DATABASE_ID FROM sres.EXTERNALDATABASE WHERE name LIKE '[species1]-[species2]_Mercator_synteny'
    )
  )
);
DELETE FROM apidb.SYNTENY WHERE EXTERNAL_DATABASE_RELEASE_ID=(
  SELECT EXTERNAL_DATABASE_RELEASE_ID FROM sres.EXTERNALDATABASERELEASE WHERE EXTERNAL_DATABASE_ID=(
    SELECT EXTERNAL_DATABASE_ID FROM sres.EXTERNALDATABASE WHERE name LIKE '[species1]-[species2]_Mercator_synteny'
  )
);
DELETE FROM sres.EXTERNALDATABASERELEASE WHERE EXTERNAL_DATABASE_ID=(
  SELECT EXTERNAL_DATABASE_ID FROM sres.EXTERNALDATABASE WHERE name LIKE '[species1]-[species2]_Mercator_synteny'
);
DELETE FROM sres.EXTERNALDATABASE WHERE name LIKE '[species1]-[species2]_Mercator_synteny';
==================

Undo complete

ERRMSG
    printf STDERR ($errMsg);
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
  my $logFile = join("/", $stepDir, "nextflow.log");

  my $cmd = "export NXF_WORK=$nextflowDataDir/work && nextflow -bg -C $nfConfigFile -log $logFile run $executable";

## If you are here to look at an example of nextflow usage:
# -bg run in background option: nextflow will not run if you run your workflow (rf run real) in a background shell
# -log : override the default (.nextflow.log)
# NXF_WORK will contain logs for individual jobs (building and loading sqlldr files)

  printf STDERR ("Running: $cmd\nSee $logFile for further details\n");
  $self->runCmd($test,$cmd,"Nextflow failed, see $logFile for details");
  if($self->scanNextflowLogForFailures($logFile)){
    $self->runCmd($test, "false", "Nextflow failed, see $logFile for details");
  }
}

sub scanNextflowLogForFailures {
  my ($self,$logFile) = @_;
  my $info;
  open(FH, "<$logFile") or die "Cannot read $logFile:$!\n";
  while(my $line=<FH>){
    if( $line =~ /nextflow\.trace\.WorkflowStatsObserver/ ){
      $info = $line;
    }
  }
  close(FH);
  $info =~ s/^.*\[|\].*$//g;
  my @stats = split /\s*;\s*/, $info;
  printf STDERR ("Nextflow Stats:\n%s\n", join("\n", @stats));
  my %statValues;
  foreach my $stat(@stats){
    my ($k,$v) = split /=/, $stat;
    $statValues{$k} = $v;
  }
  return $statValues{failedCount};
}

1;
