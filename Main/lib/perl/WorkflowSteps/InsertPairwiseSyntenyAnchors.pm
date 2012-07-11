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

    # do this explicitly because if we use the standard plugin undo, the first undo will remove
    # the alg inv ids from the workflow linking table, and the second and third will not 
    # be able to find them.
    if ($undo) {
      my $algInvIds = $self->getAlgInvIds();
      if ($algInvIds) {
	  my $cmd1 = "ga GUS::Community::Plugin::Undo --plugin ApiCommonData::Load::Plugin::InsertSyntenySpans --workflowContext --algInvocationId '$algInvIds' --commit";
	  my $cmd2 = "ga GUS::Community::Plugin::Undo --plugin GUS::Supported::Plugin::InsertExternalDatabaseRls --workflowContext --algInvocationId '$algInvIds' --commit";
	  my $cmd3 = "ga GUS::Community::Plugin::Undo --plugin GUS::Supported::Plugin::InsertExternalDatabase --workflowContext --algInvocationId '$algInvIds' --commit";

	  $self->runCmd($test, $cmd1);
	  $self->runCmd($test, $cmd2);
	  $self->runCmd($test, $cmd3);
      }
    }

    opendir(INPUT, "$workflowDataDir/$mercatorOutputsDir") or $self->error("Could not open mercator outputs dir '$mercatorOutputsDir' for reading.\n");

    foreach my $pair (readdir INPUT){
	next if ($pair =~ m/^\./);
	my ($orgAbbrevA, $orgAbbrevB) = split(/\-/, $pair);

        my $gffFileA = "$workflowDataDir/$mercatorInputsDir/${orgAbbrevA}.gff";
        my $gffFileB = "$workflowDataDir/$mercatorInputsDir/${orgAbbrevB}.gff";

	my $databaseName = "${pair}_Mercator_synteny";
	my $dbPluginArgs = "--name '$databaseName' ";
	my $releasePluginArgs = "--databaseName '$databaseName' --databaseVersion dontcare";

	my $insertPluginArgs = "--inputFile $workflowDataDir/$mercatorOutputsDir/$pair/$pair.align-synteny --syntenyDbRlsSpec '$databaseName|dontcare' --gffFileA $gffFileA --gffFileB $gffFileB";

	# command to reformat .align file
	my $inputFile = "$workflowDataDir/$mercatorOutputsDir/$pair/$pair.align";
	my $outputFile = "$workflowDataDir/$mercatorOutputsDir/$pair/$pair.align-synteny";
	my $formatCmd = "reformatMercatorAlignFile --inputFile $inputFile --outputFile $outputFile";

	if ($undo) {
	    unlink($outputFile);
	} else {
	    # allow for restart; skip those already in db.   any partially done pair needs to be fully backed out before restart.
	    my $exists = $workflowStep->runSqlFetchOneRow($test,"select name from sres.externaldatabase where name = '$databaseName'");
	    if ($exists) {
		$self->log("Pair $pair was previously loaded.  Skipping.");
		next;
	    }

	    my $tmPrefix = $self->getTuningTablePrefix($orgAbbrevB, $test);
	    my $sql = "select count(*)
                       from apidbtuning.${tmPrefix}sequenceattributes sa, apidb.organism o, sres.sequenceontology so
                       where so.term_name IN ('chromosome', 'supercontig')
                       and sa.so_id = so.so_id
                       and sa.taxon_id = o.taxon_id
                       and o.abbrev = '$orgAbbrevB'";
	    my $cmd = "getValueFromTable --idSQL \"$sql\"";
	    my $isNotDraftGenome = $self->runCmd($test, $cmd);
	    if (!$isNotDraftGenome) {
	      $formatCmd .= " --agpFile $workflowDataDir/$mercatorOutputsDir/$pair/$orgAbbrevB.agp";
	    }

	    $self->runCmd($test, $formatCmd);
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

