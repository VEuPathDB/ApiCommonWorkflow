package ApiCommonWorkflow::Main::WorkflowSteps::InsertPairwiseSyntenyAnchors;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    # the directory that has mercator output.  this is our input
    my $mercatorOutputsDir = $self->getParamValue('mercatorOutputsDir');

    my $workflowDataDir = $self->getWorkflowDataDir();

    # in test mode, there are no input files to iterate over, so just leave
    if ($test) {
	$self->testInputFile('mercatorOutputsDir', "$workflowDataDir/$mercatorOutputsDir");
	return;
    }

    opendir(INPUT, "$workflowDataDir/$mercatorOutputsDir") or $self->error("Could not open mercator outputs dir '$mercatorOutputsDir' for reading.\n");

    foreach my $pair (readdir INPUT){
	next if ($pair =~ m/^\./);
	my ($orgAbbrevA, $orgAbbrevB) = split(/\-/, $pair);

	my $databaseName = "${pair}_Mercator_synteny";
	my $dbPluginArgs = "--name '$databaseName' ";
	my $releasePluginArgs = "--databaseName '$databaseName' --databaseVersion dontcare";

	my $extDbVerA = $self->getExtDbVersion($test, "$orgAbbrevA_primary_genome_RSRC");
	my $extDbVerB = $self->getExtDbVersion($test, "$orgAbbrevB_primary_genome_RSRC");

	my $insertPluginArgs = "--inputFile $workflowDataDir/$mercatorOutputsDir/$pair/$pair.align-synteny --extDbRlsSpecA '$orgAbbrevA_primary_genome_RSRC|$extDbVerA' --extDbRlsSpecB '$orgAbbrevB_primary_genome_RSRC|$extDbVerB' --syntenyDbRlsSpec '$databaseName|dontcare'";

	# command to reformat .align file
	my $inputFile = "$workflowDataDir/$mercatorOutputsDir/$pair/$pair.align";
	my $outputFile = "$workflowDataDir/$mercatorOutputsDir/$pair/$pair.align-synteny";
	my $formatCmd = "reformatMercatorAlignFile --inputFile $inputFile --outputFile $outputFile";
	if (!$isNotDraftGenome) {
	    $formatCmd .= " --agpFile $workflowDataDir/$mercatorOutputsDir/$pair/$orgAbbrevB.agp";
	}

	if ($undo) {
	    unlink($outputFile);
	    $self->runPlugin($test, 1, "ApiCommonData::Load::Plugin::InsertPairwiseSyntenySpans", $insertPluginArgs);
	    $self->runPlugin($test, 1, "GUS::Supported::Plugin::InsertExternalDatabaseRls", $releasePluginArgs);
	    $self->runPlugin($test, 1, "GUS::Supported::Plugin::InsertExternalDatabase", $dbPluginArgs);
	} else {
	    my $tmPrefix = $self->getTuningTablePrefix($orgAbbrevB, $test);
	    my $sql = "select count(*)
                       from apidbtuning.${tmPrefix}sequenceattributes sa, apidb.organism o, sres.sequenceontology so
                       where so.term_name IN ('chromosome', 'supercontig')
                       and sa.sequence_ontology_id = so.sequence_ontology_id
                       and sa.taxon_id = o.taxon_id
                       and o.abbrev = '$orgAbbrevB'";
	    my $cmd = "getValueFromTable --idSQL \"$sql\"";
	    my $isNotDraftGenome = $self->runCmd($test, $cmd);

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

