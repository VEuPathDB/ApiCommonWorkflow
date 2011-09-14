package ApiCommonWorkflow::Main::WorkflowSteps::InsertPairwiseSyntenyAnchors;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;

    # the file that has mercator output.  this is our input
    my $mercatorOutputsDir = $self->getParamValue('mercatorOutputsDir');

    my $workflowDataDir = $self->getWorkflowDataDir();

    # in test mode, there are no input files to iterate over, so just leave
    if ($test) {
	$self->testInputFile('mercatorOutputsDir', "$workflowDataDir/$mercatorOutputsDir");
	return;
    }
    
    opendir(INPUT, "$workflowDataDir/$mercatorOutputsDir") or $self->error("Could not open mercator outputs dir '$mercatorOutputsDir' for reading.\n");

    foreach my $pairDir (readdir INPUT){
	next if ($pairDir =~ m/^\./);
	my ($orgAbbrevA, $orgAbbrevB) = split(/\-/, $pairDir);
	
	my $databaseName = "$pairDir synteny from Mercator";
	my $dbPluginArgs = "--name '$databaseName' ";
	my $releasePluginArgs = "--databaseName '$databaseName' --databaseVersion dontcare";
	my $insertPluginArgs = "--mercatorDir $workflowDataDir/$mercatorOutputsDir/$pairDir";

	if ($undo) {
	    $self->runPlugin($test, 1, "ApiCommonData::Load::Plugin::InsertPairwiseSyntenySpans", $insertPluginArgs);
	    $self->runPlugin($test, 1, "GUS::Supported::Plugin::InsertExternalDatabaseRls", $releasePluginArgs);
	    $self->runPlugin($test, 1, "GUS::Supported::Plugin::InsertExternalDatabase", $dbPluginArgs);
	} else {
	    # reformat .align file
	    my $inputFile = "$workflowDataDir/$mercatorOutputsDir/$pairDir/$pairDir.align";
	    my $outputFile = "$workflowDataDir/$mercatorOutputsDir/$pairDir/$pairDir.align-synteny";
	    my $formatCmd = "reformatMercatorAlignFile --inputFile $inputFile --outputFile $outputFile";
	    if ($self->getOrganismInfo($orgAbbrevB)->getIsDraftGenome()) {
		$formatCmd .= " --agpFile $workflowDataDir/$mercatorOutputsDir/$pairDir/$orgAbbrevB.agp";	    
	    }

	    $self->runPlugin($test, 0, "GUS::Supported::Plugin::InsertExternalDatabase", $dbPluginArgs);
	    $self->runPlugin($test, 0, "GUS::Supported::Plugin::InsertExternalDatabaseRls", $releasePluginArgs);
	    $self->runPlugin($test, 0, "ApiCommonData::Load::Plugin::InsertPairwiseSyntenySpans", $args);
	}
    }
}

sub getConfigDeclaration {
    return (
            # [name, default, description]

           );
}

