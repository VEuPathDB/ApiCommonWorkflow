package ApiCommonWorkflow::Main::WorkflowSteps::InsertPairwiseSyntenyAnchors;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;


    my $mercatorDir = $self->getParamValue('mercatorDir');
    my $organism   = $self->getParamValue('organism');
    my $mercatorDraftGenomes = $self->getParamValue('mercatorDraftGenomes');
    my $mercatorNonDraftGenomes = $self->getParamValue('mercatorNonDraftGenomes');
    my $mercatorSyntenyVersion = $self->getParamValue('mercatorSyntenyVersion');

    my $workflowDataDir = $self->getWorkflowDataDir();

    my @drafts = ();
    my @nonDrafts = ();

    my @allGenomes = ();


    my $draftIdx = -1;
    my  $nonDraftIdx = -1;

    if($mercatorDraftGenomes){
	@drafts =  map { "$_" } split(',', $mercatorDraftGenomes);

	$draftIdx = $#drafts;
    }
  
    if($mercatorNonDraftGenomes){
	@nonDrafts = map { "$_" } split(',', $mercatorNonDraftGenomes);


	$nonDraftIdx = $#nonDrafts;
    }

    push(@allGenomes,@drafts,@nonDrafts);


    my $args = "--mercatorDir $workflowDataDir/$mercatorDir --organism '$organism'";
    
    if ($test) {
	for(my $i =0; $i <= ($#allGenomes-1); $i++){
	    for(my $j =$i+1 ; $j <= $#allGenomes; $j++){
		my $dirName = "$mercatorDir/$allGenomes[$i]-$allGenomes[$j]";
		$self->testInputFile('inputFile', "$dirName/$allGenomes[$i]-$allGenomes[$j].align-synteny");
	    }
	}
    }

	for(my $i =0; $i <= ($#allGenomes-1); $i++){
	    for(my $j =$i+1 ; $j <= $#allGenomes; $j++){
		my $databaseName = "$allGenomes[$i]-$allGenomes[$j] synteny from Mercator";
		my $dbPluginArgs = "--name '$databaseName' ";
		$self->runPlugin($test, $undo, "GUS::Supported::Plugin::InsertExternalDatabase", $dbPluginArgs);
		my $releasePluginArgs = "--databaseName '$databaseName' --databaseVersion '$mercatorSyntenyVersion'";
		$self->runPlugin($test, $undo, "GUS::Supported::Plugin::InsertExternalDatabaseRls", $releasePluginArgs);
	    }
	}


    $self->runPlugin($test, $undo, "ApiCommonData::Load::Plugin::InsertPairwiseSyntenySpans", $args);

 
}

sub getParamsDeclaration {
    return ('mercatorDir',
            'organism',
	    'mercatorDraftGenomes'.
	    'mercatorNonDraftGenomes',
           );
}


sub getConfigDeclaration {
    return (
            # [name, default, description]

           );
}

