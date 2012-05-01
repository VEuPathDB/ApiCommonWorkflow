package ApiCommonWorkflow::Main::WorkflowSteps::FindOrthomclPairs;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $binPath = $self->getConfig('binPath');
  my $workflowDataDir = $self->getWorkflowDataDir();


  my $configFile = "$workflowDataDir/orthomclPairs.config";
  my $logfile = "orthomclPairs.log";

  my $cmd = "$binPath/orthomclPairs $configFile $logfile cleanup=no";

  if ($undo) {
    $self->runCmd(0, "rm -f $workflowDataDir/$logfile");
    $self->runCmd(0, "rm -f $workflowDataDir/$configFile");
  } else {
      if ($test) {
	  $self->runCmd(0,"echo test > $workflowDataDir/$logfile");
      }

      my $dsn = $self->getConfig('dsn');
      my $login = $self->getConfig('login');
      my $password = $self->getConfig('password');
      writeConfigFile($configFile, $dsn, $login, $password);
      $self->runCmd($test,$cmd);
  }
}

sub writeConfigFile {
  my ($configFile, $dsn, $login, $password) = @_;

  open(CONFIG, ">$configFile") || die "Can't open '$configFile' for writing";
  print CONFIG <<"EOF";
dbConnectString=$dsn
dbLogin=$login
dbPassword=$password
dbVendor=oracle
similarSequencesTable=apidb.SimilarSequences
orthologTable=apidb.Ortholog
inParalogTable=apidb.InParalog
coOrthologTable=apidb.CoOrtholog
interTaxonMatchView=apidb.InterTaxonMatch
percentMatchCutoff=50
evalueExponentCutoff=-5
EOF

  close(CONFIG);
}


# below is a (temporary) copy of the predecessor from Steps.pm
sub orthomclPairs {
  my ($mgr, $cleanup, $startAfter) = @_;

  my $signal = 'findOrthoMclPairs';

  return if $mgr->startStep("Find pairs for orthoMCL", $signal);

  my $logfile = "$mgr->{myPipelineDir}/logs/$signal.log";

  my $propertySet = $mgr->{propertySet};

  my $gus_config_file = $propertySet->getProp('gusConfigFile');

  my @properties = ();
  my $gusconfig = CBIL::Util::PropertySet->new($gus_config_file, \@properties, 1);
  my $login = $gusconfig->{props}->{databaseLogin};
  my $password = $gusconfig->{props}->{databasePassword};
  my $dsn = $gusconfig->{props}->{dbiDsn};

my $configString =
"dbConnectString=$dsn
dbLogin=$login
dbPassword=$password
dbVendor=oracle
similarSequencesTable=apidb.SimilarSequences
orthologTable=apidb.Ortholog
inParalogTable=apidb.InParalog
coOrthologTable=apidb.CoOrtholog
interTaxonMatchView=apidb.InterTaxonMatch
percentMatchCutoff=50
evalueExponentCutoff=-5
";

  my $configFile = $propertySet->getProp('orthoMclPairsConfig');;
  open(CONFIG, ">$configFile") || die "Can't open '$configFile' for writing";
  print CONFIG $configString;
  close(CONFIG);

  my $cmd = "nohup orthomclPairs $configFile $logfile cleanup=$cleanup";

  $cmd .= " startAfter=$startAfter" if $startAfter;

  $mgr->runCmd($cmd);

  $mgr->endStep($signal);

}
