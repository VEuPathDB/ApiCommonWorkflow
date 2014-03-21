package ApiCommonWorkflow::Main::WorkflowSteps::InsertPairwiseSyntenyAnchors;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    # the directory that has mercator output.  this is our input
    my $mercatorOutputsDir = $self->getParamValue('mercatorOutputsDir');
    my $mercatorInputsDir = $self->getParamValue('mercatorInputsDir'); # holds lots of .gff and .fasta files

    my $workflowDataDir = $self->getWorkflowDataDir();

    # in test mode, there are no input files to iterate over, so just leave
    if ($test) {
	$self->testInputFile('mercatorOutputsDir', "$workflowDataDir/$mercatorOutputsDir");
	return;
    }

    # Do this explicitly because if we use the standard plugin undo, the first undo will remove
    # the alg inv ids from the workflow linking table, and the rest of the plugin undos
    # will not be able to find them.
    # Divide into chunks of 100 to avoid overwhelming the command line
    if ($undo) {
      my $algInvIdsFull = $self->getAlgInvIds();
      if ($algInvIdsFull) {
	  my @algInvIdsArray = split(/,/, $algInvIdsFull);
	  my $count = scalar(@algInvIdsArray);
	  for (my $i=0; $i<$count; $i+=99) {
	      my @subArray = splice(@algInvIdsArray, 0, 99);
	      my $algInvIds = join(",", @subArray);
	      my $cmd1 = "ga GUS::Community::Plugin::Undo --plugin ApiCommonData::Load::Plugin::InsertSyntenySpans --workflowContext --algInvocationId '$algInvIds' --commit";
	      my $cmd2 = "ga GUS::Community::Plugin::Undo --plugin GUS::Supported::Plugin::InsertExternalDatabaseRls --workflowContext --algInvocationId '$algInvIds' --commit";
	      my $cmd3 = "ga GUS::Community::Plugin::Undo --plugin GUS::Supported::Plugin::InsertExternalDatabase --workflowContext --algInvocationId '$algInvIds' --commit";

	      $self->runCmd($test, $cmd1);
	      $self->runCmd($test, $cmd2);
	      $self->runCmd($test, $cmd3);
	  }
      }
    }

    opendir(INPUT, "$workflowDataDir/$mercatorOutputsDir") or $self->error("Could not open mercator outputs dir '$mercatorOutputsDir' for reading.\n");

    foreach my $pair (readdir INPUT){
	next if ($pair =~ m/^\./);
	#my ($orgAbbrevA, $orgAbbrevB) = split(/\-/, $pair);
        my $ndelim = $pair =~ tr/\-//;
	my @orgAbbrevs = split(/\-/, $pair, $ndelim + 1);
	my ($orgAbbrevA, $orgAbbrevB);

	while(scalar @orgAbbrevs >1){
	    my $tmp=pop(@orgAbbrevs);
	    $orgAbbrevB = $tmp . $orgAbbrevB;
	    my $exists = $self->runSqlFetchOneRow($test,"select abbrev from apidb.organism where abbrev = '$orgAbbrevB'");
	    if ($exists) {
		$self->log("orgAbbrevB is '$orgAbbrevB'.");
		last;
	    }else{
		$orgAbbrevB = "-".$orgAbbrevB;
	    }
            
	}

	while(scalar @orgAbbrevs >0){
	    my $tmp=pop(@orgAbbrevs);
	    $orgAbbrevA = $tmp . $orgAbbrevA;
	    my $exists = $self->runSqlFetchOneRow($test,"select abbrev from apidb.organism where abbrev = '$orgAbbrevA'");
	    if ($exists) {
		$self->log("orgAbbrevA is '$orgAbbrevA'.");
		last;
	    }else{
		$orgAbbrevA = "-" . $orgAbbrevA;
	    }
            
	}

	my $databaseName = "${pair}_Mercator_synteny";
	my $dbPluginArgs = "--name '$databaseName' ";
	my $releasePluginArgs = "--databaseName '$databaseName' --databaseVersion dontcare";

	my $insertPluginArgs = "--inputDirectory $workflowDataDir/$mercatorOutputsDir/$pair --syntenyDbRlsSpec '$databaseName|dontcare'";


	if ($undo) {
#	    unlink($outputFile);
	} else {
	    # allow for restart; skip those already in db.   any partially done pair needs to be fully backed out before restart.
	    my $exists = $self->runSqlFetchOneRow($test,"select name from sres.externaldatabase where name = '$databaseName'");
	    if ($exists) {
		$self->log("Pair $pair was previously loaded.  Skipping.");
		next;
	    }


	    $self->runPlugin($test, 0, "GUS::Supported::Plugin::InsertExternalDatabase", $dbPluginArgs);
	    $self->runPlugin($test, 0, "GUS::Supported::Plugin::InsertExternalDatabaseRls", $releasePluginArgs);
	    $self->runPlugin($test, 0, "ApiCommonData::Load::Plugin::InsertSyntenySpans", $insertPluginArgs);
	}
    }
}

sub getConfigDeclaration {
    return (
            # [name, default, description]

           );
}

