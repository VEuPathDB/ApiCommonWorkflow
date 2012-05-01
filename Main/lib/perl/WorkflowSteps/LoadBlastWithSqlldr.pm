package ApiCommonWorkflow::Main::WorkflowSteps::LoadBlastWithSqlldr;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');

  my $sqlldrBinPath = $self->getConfig('sqlldrBinPath');
  my $oraclePassword = $self->getConfig('oraclePassword');
  my $workflowDataDir = $self->getWorkflowDataDir();

  my $ctlFile = "$workflowDataDir/blast.ctl";
  my $logFile = "$workflowDataDir/sqlldr.log";
  my $cmd = "$sqlldrBinPath/sqlldr $oraclePassword data=$workflowDataDir/$inputFile control=$ctlFile log=$logFile rows=25000 direct=TRUE";

  if ($undo) {
    $self->runCmd(0, "rm -f $ctlFile");
  } else {
      if ($test) {
	  $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");
      }

      writeControlFile($ctlFile);
      $self->runCmd($test, $cmd);
  }
}

sub writeControlFile {
  my ($ctlFile) = @_;

  open(CTL, ">$ctlFile") || die "Can't open '$ctlFile' for writing";
  print CTL <<"EOF";
     LOAD DATA
     INFILE *
     INTO TABLE apidb.similarsequences
     FIELDS TERMINATED BY " " OPTIONALLY ENCLOSED BY '"'
     TRAILING NULLCOLS
    (query_id,
     subject_id,
     query_taxon_id,
     subject_taxon_id,
     evalue_mant,
     evalue_exp,
     percent_identity,
     percent_match
    )
EOF

  close(CTL);
}

# predecessor from Steps.pm
sub loadBlastWithSqlldr {
  my ($mgr,$blastName,$restart,$file, $ctl) = @_;

  my $signal = "sqlldrLoad$blastName";

  return if $mgr->startStep("Load $blastName using sqldr", $signal);

  my $sqlldrFile = "$mgr->{dataDir}/similarity/$blastName/master/mainresult/blastSimForSqlldr.out";

  if ($file) {
    $sqlldrFile = "$mgr->{dataDir}/similarity/$blastName/master/mainresult/$file";

    $mgr->runCmd("gunzip $sqlldrFile") if $sqlldrFile =~ /\.gz/;
    $sqlldrFile =~ s/\.gz//;
  }

  my $ctlFile = "$mgr->{dataDir}/similarity/$blastName/master/mainresult/$ctl" if $ctl;

  my $logfile = "$mgr->{myPipelineDir}/logs/$signal.log";

  die "$sqlldrFile file doesn't exist\n" unless (-e $sqlldrFile);

  my $propertySet = $mgr->{propertySet};

  my $oracleUserPswd = $propertySet->getProp('oracleUserPswd');

  my $cmd = "nohup sqlldr $oracleUserPswd control=$sqlldrFile log=$logfile rows=25000 direct=TRUE";

  $cmd = "nohup sqlldr $oracleUserPswd data=$sqlldrFile control=$ctlFile log=$logfile rows=25000 direct=TRUE" if $ctl;

  $cmd .= " SKIP=$restart" if $restart;

  $mgr->runCmd($cmd);

  $mgr->endStep($signal);


}
