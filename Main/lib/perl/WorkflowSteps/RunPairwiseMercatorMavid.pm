package ApiCommonWorkflow::Main::WorkflowSteps::RunPairwiseMercatorMavid;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;


    my $mercatorDir = $self->getParamValue('mercatorDir');
    my $mercatorDraftGenomes = $self->getParamValue('mercatorDraftGenomes');
    my $mercatorNonDraftGenomes = $self->getParamValue('mercatorNonDraftGenomes');
    my $cndsrcBin = $self->getParamValue('cndSrcBin');
    my $mavid = $self->getParamValue('mavidExe');


    my $localDataDir = $self->getLocalDataDir();
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

    for(my $i =0; $i <= ($#allGenomes-1); $i++){
	for(my $j =$i+1 ; $j <= $#allGenomes; $j++){
	    my $dirName = "$mercatorDir/$allGenomes[$i]-$allGenomes[$j]";

	    my $command = "runMercator  -t '($allGenomes[$i]:0.1,$allGenomes[$j]:0.1);' -p $dirName -c $cndsrcBin -m $mavid ";
	    if($i <= $draftIdx){
		$command .= "-d  $allGenomes[$i] ";
	    }else{
		$command .= "-n $allGenomes[$i] ";
	    }
	    if($j <= $draftIdx){
		$command .= "-d  $allGenomes[$j] ";
	    }else{
		$command .= "-n $allGenomes[$j] ";
	    }
	    if ($undo) {
		$self->runCmd(0, "rm -fr $dirName/*.align");
		$self->runCmd(0,"rm -fr $dirName/mercator-output");
		$self->runCmd(0,"rm -fr $dirName/mercator-input");
	    }else{
		if ($test) {
		$self->runCmd(0,"mkdir -p $dirName/mercator-output");
		$self->runCmd(0,"mkdir -p $dirName/mercator-input");		    
		    $self->runCmd(0,"echo hello > $dirName/$allGenomes[$i]-$allGenomes[$j]".".align");
		}else{		
		    $self->runCmd($test,$command);
		}
	    }
	}
    }



 
}

sub getParamsDeclaration {
    return ('mercatorDir',
            'mercatorDraftGenomes',
            'mercatorNonDraftGenomes',
	    'cndSrcBin',
            'mavidExe',
           );
}


sub getConfigDeclaration {
    return (
            # [name, default, description]

           );
}
