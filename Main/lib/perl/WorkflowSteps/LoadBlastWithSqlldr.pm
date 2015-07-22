package ApiCommonWorkflow::Main::WorkflowSteps::LoadBlastWithSqlldr;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;


sub run {
  my ($self, $test, $undo) = @_;

  my $inputFile = $self->getParamValue('inputFile');
  my $dataDir = $self->getParamValue('dataDir');
  my $suffix = $self->getParamValue('suffix');

  my $gusInstance = $self->getGusInstanceName();
  my $gusLogin = $self->getGusDatabaseLogin();
  my $gusPassword = $self->getGusDatabasePassword();

  my $workflowDataDir = $self->getWorkflowDataDir();

  mkdir "$workflowDataDir/$dataDir" || die "could not create working dir '$workflowDataDir/$dataDir' \n";

  my $ctlFile = "$workflowDataDir/$dataDir/blast.ctl";
  my $sqlldrLog = "$workflowDataDir/$dataDir/sqlldr.log";

  if ($undo) {
    if (!$test) {
	$self->log("Truncating apidb.similarsequences$suffix");
	$self->runSqlFetchOneRow(0,"truncate table apidb.similarsequences$suffix");
	my $count = $self->runSqlFetchOneRow(0,"select count(*) from apidb.similarsequences$suffix");
	$self->error("Truncate of apidb.similarsequences$suffix did not succeed.  Table is not empty ($count rows)") if $count;
	$self->log("Done truncating");
    }
    $self->runCmd(0, "rm -f $ctlFile") if -e $ctlFile;
    $self->runCmd(0, "rm -f $sqlldrLog") if -e $sqlldrLog;
  } else {

    $self->testInputFile('inputFile', "$workflowDataDir/$inputFile");

    # confirm that the target table is empty.  this is required so that our undo strategy (truncating) will work
    if (!$test) {
	my $count = $self->runSqlFetchOneRow(0,"select count(*) from apidb.similarsequences$suffix");
	$self->error("Table apidb.similarsequences$suffix is not empty ($count rows)") if $count;
    }

    # run sqlldr (after writing its control file)
    writeControlFile($ctlFile, $suffix);
    my $cmd = "sqlldr $gusLogin/$gusPassword\@$gusInstance data=$workflowDataDir/$inputFile control=$ctlFile log=$sqlldrLog rows=25000 direct=TRUE";
    $self->runCmd($test, $cmd);
  }
}

sub writeControlFile {
  my ($ctlFile, $suffix) = @_;

  open(CTL, ">$ctlFile") || die "Can't open '$ctlFile' for writing";
  print CTL <<"EOF";
     LOAD DATA
     INFILE *
     INTO TABLE apidb.similarsequences$suffix
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


1;
