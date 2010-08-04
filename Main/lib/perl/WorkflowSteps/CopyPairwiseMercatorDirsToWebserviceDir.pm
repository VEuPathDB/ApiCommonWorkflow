package ApiCommonWorkflow::Main::WorkflowSteps::CopyPairwiseMercatorDirsToWebserviceDir;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
    my ($self, $test, $undo) = @_;


    my $mercatorDir = $self->getParamValue('mercatorDir');
    my $apiSiteFilesDir   = $self->getParamValue('apiSiteFilesDir');
    my $workflowDataDir = $self->getWorkflowDataDir();

    opendir(MERCATORDIR,"$workflowDataDir/$mercatorDir") or $self->error("Could not open $workflowDataDir/$mercatorDir for reading.\n");

    
    foreach my $subDir (readdir MERCATORDIR){
	
	if ($undo) {
	    $self->runCmd(0, "rm -fr $apiSiteFilesDir/*");
	}else{
	    if ($test) {
		$self->runCmd(0,"mkdir -p $apiSiteFilesDir/$subDir");
		$self->runCmd(0,"cp -R $workflowDataDir/$mercatorDir/$subDir/mercator-output/alignments $apiSiteFilesDir/$subDir");
		$self-runCmd(0,"cp -R $workflowDataDir/mercatorDir/$subDir/mercator-output/*.agp $apiSiteFilesDir/$subDir");
	    }else{		
		$self->runCmd($test,"mkdir -p $apiSiteFilesDir/$subDir");
		$self->runCmd($test,"cp -R $workflowDataDir/$mercatorDir/$subDir/mercator-output/alignments $apiSiteFilesDir/$subDir");
		$self-runCmd($test,"cp -R $workflowDataDir/$mercatorDir/$subDir/mercator-output/*.agp $apiSiteFilesDir/$subDir");		    
	    }
	}
	
    }

 
}

sub getParamsDeclaration {
    return ('mercatorDir',
            'apiSiteFilesDir',
	    'workflowDataDir',
           );
}


sub getConfigDeclaration {
    return (
            # [name, default, description]

           );
}

