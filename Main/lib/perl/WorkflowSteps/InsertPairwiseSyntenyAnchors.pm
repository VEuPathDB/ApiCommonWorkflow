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
	my $insertPluginArgs = "--mercatorDir $workflowDataDir/$mercatorOutputsDir/$pair --syntenyDbRlsSpec $databaseName|dontcare";

	if ($undo) {
	    $self->runPlugin($test, 1, "ApiCommonData::Load::Plugin::InsertPairwiseSyntenySpans", $insertPluginArgs);
	    $self->runPlugin($test, 1, "GUS::Supported::Plugin::InsertExternalDatabaseRls", $releasePluginArgs);
	    $self->runPlugin($test, 1, "GUS::Supported::Plugin::InsertExternalDatabase", $dbPluginArgs);
	} else {
	    # reformat .align file
	    my $inputFile = "$workflowDataDir/$mercatorOutputsDir/$pair/$pair.align";
	    my $outputFile = "$workflowDataDir/$mercatorOutputsDir/$pair/$pair.align-synteny";
	    my $formatCmd = "reformatMercatorAlignFile --inputFile $inputFile --outputFile $outputFile";
	    if ($self->getOrganismInfo($orgAbbrevB)->getIsDraftGenome()) {
		$formatCmd .= " --agpFile $workflowDataDir/$mercatorOutputsDir/$pair/$orgAbbrevB.agp";
	    }

	    $self->runPlugin($test, 0, "GUS::Supported::Plugin::InsertExternalDatabase", $dbPluginArgs);
	    $self->runPlugin($test, 0, "GUS::Supported::Plugin::InsertExternalDatabaseRls", $releasePluginArgs);
	    $self->runPlugin($test, 0, "ApiCommonData::Load::Plugin::InsertPairwiseSyntenySpans", $insertPluginArgs);
	}
    }
}

sub getConfigDeclaration {
    return (
            # [name, default, description]

           );
}

